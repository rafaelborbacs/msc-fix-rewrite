defmodule UploaderGWeb.UnitLive.Index do
  use UploaderGWeb, :live_view

  alias UploaderG.Entities
  alias UploaderG.Entities.Unit
  alias Phoenix.PubSub
  alias UploaderG.MQTT
  alias UploaderG.Logging

  # topic is the topic name which our live view process will subcribe to
  @topic_unit_created "unit:created"
  @topic_unit_updated "unit:updated"

  @impl true
  def mount(_params, _session, socket) do
    Phoenix.PubSub.subscribe(UploaderG.PubSub, @topic_unit_created)
    Phoenix.PubSub.subscribe(UploaderG.PubSub, @topic_unit_updated)

    {
      :ok,
      socket
      |> assign(:new_units, list_units(:unauthorized, :new))
      |> assign(:active_units, list_units(:authorized, :active))
      |> assign(:inactive_units, list_units(:authorized, :inactive))
      |> assign(:rejected_units, list_units(:unauthorized, :old))
      # |> assign(:filtered_units, [])
    }
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Editar Unidade")
    |> assign(:unit, Entities.get_unit!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "Nova Unidade")
    |> assign(:unit, %Unit{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Unidades")
    |> assign(:unit, nil)
  end

  # list only online units
  defp apply_action(socket, :list_online, _params) do
    socket
    |> assign(:page_title, "Unidades Online")
    |> assign(:unit, nil)
    |> assign(
      :filtered_units,
      list_units()
      |> Enum.filter(fn u -> u.authorized == true and u.status == true end)
    )
  end

  # list only offline units
  defp apply_action(socket, :list_offline, _params) do
    socket
    |> assign(:page_title, "Unidades Offline")
    |> assign(:unit, nil)
    |> assign(
      :filtered_units,
      list_units()
      |> Enum.filter(fn u -> u.authorized == true and u.status == false end)
    )
  end

  # list only pending units
  defp apply_action(socket, :list_pending, _params) do
    socket
    |> assign(:page_title, "Unidades Pendentes")
    |> assign(:unit, nil)
    |> assign(
      :filtered_units,
      list_units()
      |> Enum.filter(fn u -> u.authorized == false end)
    )
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    unit = Entities.get_unit!(id)
    {:ok, _} = Entities.delete_unit(unit)

    {
      :noreply,
      socket
      |> assign(:new_units, list_units(:unauthorized, :new))
      |> assign(:active_units, list_units(:authorized, :active))
      |> assign(:inactive_units, list_units(:authorized, :inactive))
      |> assign(:rejected_units, list_units(:unauthorized, :old))
    }
  end

  @impl true
  def handle_event("refuse", %{"id" => id}, socket) do
    # Get the previous unit state
    {:ok, struct} =
      Entities.get_unit!(id)
      # Update the unit state with authorized: true
      |> Entities.update_unit(%{authorized: false, new: false})

    # Get the unit target_unit_identifier from the struct
    target_unit_identifier = struct.transmits_to

    # Get the origin unit identifier from the struct
    origin_unit_identifier = struct.public_key_identifier

    # Get the public key from the struct
    public_key = struct.public_key

    # Use MQTT to send the connect command to the target unit
    MQTT.publish(
      "G/disconnect/T/#{origin_unit_identifier}/R/#{target_unit_identifier}",
      public_key
    )

    PubSub.broadcast(
      UploaderG.PubSub,
      "unit:updated",
      {:unit_updated, struct}
    )

    Logging.create_log(
      %{
        event: "Unidade Rejeitada",
        logged_at: DateTime.utc_now(),
        message: "UUID: #{target_unit_identifier}",
        origin: target_unit_identifier,
      }
    )

    {
      :noreply,
      socket
      |> assign(:new_units, list_units(:unauthorized, :new))
      |> assign(:active_units, list_units(:authorized, :active))
      |> assign(:inactive_units, list_units(:authorized, :inactive))
      |> assign(:rejected_units, list_units(:unauthorized, :old))
    }
  end

  @impl true
  def handle_event("accept", %{"id" => id}, socket) do
    # Get the previous unit state
    {:ok, struct} =
      Entities.get_unit!(id)
      # Update the unit state with authorized: true
      |> Entities.update_unit(%{authorized: true, new: false})

    # Get the unit target_unit_identifier from the struct
    target_unit_identifier = struct.transmits_to

    # Get the origin unit identifier from the struct
    origin_unit_identifier = struct.public_key_identifier

    # Get the public key from the struct
    public_key = struct.public_key

    # Use MQTT to send the connect command to the target unit
    MQTT.publish(
      "G/connect/T/#{origin_unit_identifier}/R/#{target_unit_identifier}",
      public_key
    )

    PubSub.broadcast(
      UploaderG.PubSub,
      "unit:updated",
      {:unit_updated, struct}
    )

    Logging.create_log(
      %{
        event: "Unidade Aceita",
        logged_at: DateTime.utc_now(),
        message: "UUID: #{target_unit_identifier}",
        origin: target_unit_identifier,
      }
    )

    {
      :noreply,
      socket
      |> assign(:new_units, list_units(:unauthorized, :new))
      |> assign(:active_units, list_units(:authorized, :active))
      |> assign(:inactive_units, list_units(:authorized, :inactive))
      |> assign(:rejected_units, list_units(:unauthorized, :old))
    }
  end

  def handle_info({:unit_created, unit}, socket) do
    {:noreply, assign(socket, :new_units, list_units(:unauthorized))}
  end

  def handle_info({:unit_updated, unit}, socket) do
    # Search on the assigns for a unit with the same public key identifier
    unit_to_update =
      Enum.find(
        socket.assigns.authorized_units ++
          socket.assigns.unauthorized_units,
        fn t -> t.public_key_identifier == unit.public_key_identifier end
      )

    if unit_to_update.authorized do
      # Remove such unit from the assigns
      without_unit_to_update = List.delete(socket.assigns.authorized_units, unit_to_update)
      # Add the updated unit to the assigns
      {
        :noreply,
        socket |> assign(:authorized_units, [unit | without_unit_to_update])
      }
    else
      # Remove such unit from the assigns
      without_unit_to_update = List.delete(socket.assigns.unauthorized_units, unit_to_update)

      # Add the updated unit to the assigns
      {
        :noreply,
        socket |> assign(:new_units, [unit | without_unit_to_update])
      }
    end
  end

  defp list_units(:unauthorized) do
    Entities.list_units() |> Enum.filter(fn t -> t.authorized == false end)
  end

  defp list_units(:unauthorized, :new) do
    Entities.list_units() |> Enum.filter(fn t -> t.authorized == false and t.new == true end)
  end

  defp list_units(:unauthorized, :old) do
    Entities.list_units() |> Enum.filter(fn t -> t.authorized == false and t.new == false end)
  end

  defp list_units(:authorized) do
    Entities.list_units()
    |> Enum.filter(fn u -> u.authorized == true end)
  end

  defp list_units(:authorized, :active) do
    Entities.list_units()
    |> Enum.filter(fn t -> t.authorized == true end)
    |> Enum.filter(fn t -> t.status == true end)
    |> Enum.map(fn u -> {u, verify_has_connection_requests(u)} end)
    |> IO.inspect()
  end

  defp list_units(:authorized, :inactive) do
    Entities.list_units()
    |> Enum.filter(fn t -> t.authorized == true end)
    |> Enum.filter(fn t -> t.status == false end)
  end

  defp list_units(:new) do
    Entities.list_units() |> Enum.filter(fn t -> t.new == true end)
  end

  defp list_units do
    Entities.list_units()
  end

  defp verify_has_connection_requests(unit) do
    Entities.list_units(:requested_connection, :unit, unit.id) |> Enum.count() > 0
  end

  defp compute_uploader_type(r_enabled?, t_enabled?) do
    case {r_enabled?, t_enabled?} do
      {true, true} ->
        "Inconsistência"

      {false, false} ->
        "Desativado"

      {true, false} ->
        "Receptor"

      {false, true} ->
        "Transmissor"

      _ ->
        "Desconhecido"
    end
  end

  defp compute_uploader_status(status?, authorized?) do
    case {status?, authorized?} do
      {true, true} ->
        "Online"

      {false, false} ->
        "Inconsistência"

      {true, false} ->
        "Pendente"

      {false, true} ->
        "Offline"

      _ ->
        "Inconsistência"
    end
  end

  defp render_has_connection_requests_row(assigns) do
    if assigns.has_connection_requests do
~H"""
      <tr class="bg-yellow-100 border-b dark:bg-gray-800 dark:border-gray-700 hover:bg-yellow-200 dark:hover:bg-gray-600">
                <th
                  scope="row"
                  class="px-6 py-4 font-medium text-gray-900 dark:text-white whitespace-nowrap"
                >
                  <%= @unit.id %>
                </th>

                <td class="px-6 py-4">
                  <%= @unit.location %>
                </td>

                <td class="px-6 py-4">
                  <%= @unit.host %>
                </td>

                <td class="px-6 py-4">
                  <%= @unit.port %>
                </td>

                <td class="px-6 py-4">
                  <%= compute_uploader_type(@unit.r_enabled, @unit.t_enabled) %>
                </td>

                <td class="px-6 py-4">
                  <%= compute_uploader_status(@unit.status, @unit.authorized) %>
                </td>

                <td>
                  <%= live_redirect("Detalhes",
                    to: Routes.unit_show_path(@socket, :show, @unit),
                    class: ["font-medium text-blue-600 dark:text-blue-500 hover:underline"]
                  ) %>
                  <%= live_patch("Editar",
                    to: Routes.unit_index_path(@socket, :edit, @unit),
                    class: ["font-medium text-blue-800 hover:underline"]
                  ) %>
                  <span>
                    <%= link("Desconectar",
                      to: "#",
                      phx_click: "refuse",
                      phx_value_id: @unit.id,
                      data: [confirm: "Você tem certeza?"],
                      class: ["font-medium text-red-700 hover:underline"]
                    ) %>
                  </span>
                </td>
              </tr>
    """
    else
    ~H"""
      <tr class="bg-white border-b dark:bg-gray-800 dark:border-gray-700 hover:bg-gray-50 dark:hover:bg-gray-600">
                <th
                  scope="row"
                  class="px-6 py-4 font-medium text-gray-900 dark:text-white whitespace-nowrap"
                >
                  <%= @unit.id %>
                </th>

                <td class="px-6 py-4">
                  <%= @unit.location %>
                </td>

                <td class="px-6 py-4">
                  <%= @unit.host %>
                </td>

                <td class="px-6 py-4">
                  <%= @unit.port %>
                </td>

                <td class="px-6 py-4">
                  <%= compute_uploader_type(@unit.r_enabled, @unit.t_enabled) %>
                </td>

                <td class="px-6 py-4">
                  <%= compute_uploader_status(@unit.status, @unit.authorized) %>
                </td>

                <td>
                  <%= live_redirect("Detalhes",
                    to: Routes.unit_show_path(@socket, :show, @unit),
                    class: ["font-medium text-blue-600 dark:text-blue-500 hover:underline"]
                  ) %>
                  <%= live_patch("Editar",
                    to: Routes.unit_index_path(@socket, :edit, @unit),
                    class: ["font-medium text-blue-800 hover:underline"]
                  ) %>
                  <span>
                    <%= link("Desconectar",
                      to: "#",
                      phx_click: "refuse",
                      phx_value_id: @unit.id,
                      data: [confirm: "Você tem certeza?"],
                      class: ["font-medium text-red-700 hover:underline"]
                    ) %>
                  </span>
                </td>
              </tr>
    """
    end
  end

end

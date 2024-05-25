defmodule UploaderGWeb.UnitLive.Show do
  use UploaderGWeb, :live_view

  alias UploaderG.Entities

  alias UploaderG.SSH

  alias UploaderG.Logging

  alias Phoenix.PubSub
  alias UploaderG.MQTT

  # topic is the topic name which our live view process will subcribe to
  @topic_unit_updated "unit:updated"

  @impl true
  def mount(_params, _session, socket) do
    Phoenix.PubSub.subscribe(UploaderG.PubSub, @topic_unit_updated)
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:unit, Entities.get_unit!(id))
     |> assign(:connection_accepted_units, list_units(:connected, :unit, id))
     |> assign(:connection_requested_units, list_units(:requested_connection, :unit, id))
     |> assign(:logs, list_logs(id, :by_unit))}
  end

  defp page_title(:show), do: "Detalhes da Unidade"
  defp page_title(:edit), do: "Editar Unidade"

  def compute_uploader_type(r_enabled?, t_enabled?) do
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

  defp format_date(%DateTime{} = date) do
    Calendar.strftime(date, "%d/%m/%y às %H:%M:%S")
  end

  defp get_unit_by_key(nil) do
    "—"
  end

  defp get_unit_by_key(key) do
    unit = Entities.get_unit(key, :by_public_key)

    if unit do
      unit.location
    else
      "—"
    end
  end

  @impl true
  def handle_event("accept", %{"id" => id}, socket) do
    IO.inspect("Teste")
    # Get the previous unit state
    {:ok, struct} =
      Entities.get_unit!(id)
      |> IO.inspect()
      # Update the unit state with authorized: true
      |> Entities.update_unit(%{receiver_accepted: true})

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

    {
      :noreply,
      socket
      |> assign(:page_title, page_title(socket.assigns.live_action))
      |> assign(:connection_accepted_units, list_units(:connected, :unit, id))
      |> assign(:connection_requested_units, list_units(:requested_connection, :unit, id))
      |> assign(:logs, list_logs(id, :by_unit))
    }
  end

  @impl true
  def handle_event("refuse", %{"id" => id}, socket) do
    # Get the previous unit state
    {:ok, struct} =
      Entities.get_unit!(id)
      |> IO.inspect()
      # Update the unit state with authorized: true
      |> Entities.update_unit(%{receiver_accepted: false, authorized: false})

    # Get the unit target_unit_identifier from the struct
    target_unit_identifier = struct.transmits_to

    struct
    # Update the unit state with authorized: true
    |> Entities.update_unit(%{transmits_to: ""})

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

    {
      :noreply,
      socket
      |> assign(:page_title, page_title(socket.assigns.live_action))
      |> assign(:connection_accepted_units, list_units(:connected, :unit, id))
      |> assign(:connection_requested_units, list_units(:requested_connection, :unit, id))
      |> assign(:logs, list_logs(id, :by_unit))
    }
  end

  def handle_info({:unit_updated, unit}, socket) do
    # IO.inspect(unit)
  end

  def list_units(:requested_connection, :unit, unit_id) do
    Entities.list_units(:requested_connection, :unit, unit_id)
  end

  def list_units(:connected, :unit, unit_id) do
    Entities.list_units(:connected, :unit, unit_id)
  end

  def list_logs(unit_id, :by_unit) do
    Logging.list_logs(unit_id, :by_unit)
  end
end

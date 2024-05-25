defmodule UploaderGWeb.DashboardLive.Index do
  use UploaderGWeb, :live_view

  alias UploaderG.Entities
  alias UploaderG.Entities.Unit
  alias UploaderG.Operation
  alias Phoenix.PubSub
  alias UploaderG.MQTT

  @topic_unit_created "unit:created"
  @topic_unit_updated "unit:updated"

  @impl true
  def mount(_params, _session, socket) do
    Phoenix.PubSub.subscribe(UploaderG.PubSub, @topic_unit_created)
    Phoenix.PubSub.subscribe(UploaderG.PubSub, @topic_unit_updated)

    {
      :ok,
      socket
      |> assign(:current_page, 1)
      |> assign(:transmissions, list_transmissions())
      |> assign(:online_units_count, count_online_units())
      |> assign(:offline_units_count, count_offline_units())
      |> assign(:pending_units_count, count_pending_units())
      |> assign(:transmissions_count, count_transmissions(list_transmissions()))
      |> assign(:average_transmission_time, get_average_transmission_time())
      |> assign(:transmissions_count_by_uploader, count_transmissions_by_uploader())
      |> assign(:volumes_by_origin, get_volumes_by_origin())
      |> assign(:units, list_units(:authorized))
      |> assign(:current_origin, "Escolha um Transmissor")
    }
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  def handle_info({:unit_created, _unit}, socket) do
    {
      :noreply,
      assign(socket, :pending_units_count, socket.assigns.pending_units_count + 1)
    }
  end

  def handle_info({:unit_updated, unit}, socket) do
    if unit.authorized and unit.status do
      {
        :noreply,
        socket
        |> assign(:online_units_count, socket.assigns.online_units_count + 1)
        |> assign(:pending_units_count, socket.assigns.pending_units_count - 1)
      }
    end

    if unit.status == false do
      {
        :noreply,
        socket
        |> assign(:offline_units_count, socket.assigns.offline_units_count + 1)
        |> assign(:online_units_count, socket.assigns.online_units_count - 1)
      }
    end
  end

  def handle_event("origin_changed", %{"origin" => %{"origin" => new_origin}}, socket) do
    IO.inspect(new_origin)

    {
      :noreply,
      assign(socket, :transmissions_count_by_uploader, count_transmissions_by_uploader())
    }
  end

  def handle_event("save", %{"origin" => %{"origin" => new_origin}}, socket) do
    if new_origin != "" do
      {
        :noreply,
        socket
        |> assign(:transmissions_count_by_uploader, count_transmissions_by_uploader(new_origin))
        |> assign(:average_transmission_time, get_average_transmission_time(new_origin))
        |> assign(:transmissions, list_transmissions(new_origin))
        |> assign(:transmissions_count_by_uploader, count_transmissions_by_uploader(new_origin))
        |> assign(:volumes_by_origin, get_volumes_by_origin(new_origin))
        |> assign(:current_origin, new_origin)
      }
    else
      {
        :noreply,
        socket
        |> assign(:current_page, 1)
        |> assign(:transmissions, list_transmissions())
        |> assign(:online_units_count, count_online_units())
        |> assign(:offline_units_count, count_offline_units())
        |> assign(:pending_units_count, count_pending_units())
        |> assign(:transmissions_count, count_transmissions(list_transmissions()))
        |> assign(:average_transmission_time, get_average_transmission_time())
        |> assign(:transmissions_count_by_uploader, count_transmissions_by_uploader())
        |> assign(:volumes_by_origin, get_volumes_by_origin())
        |> assign(:units, list_units(:authorized))
        |> assign(:current_origin, "Escolha um Transmissor")
      }
    end
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Dashboard")
    |> assign(:unit, nil)
  end

  defp list_transmissions do
    Operation.list_transmissions()
  end

  defp list_transmissions(origin) do
    Operation.list_transmissions(:by_origin, origin)
  end

  defp list_units(:authorized) do
    units =
      Entities.list_units()
      |> Enum.filter(fn u -> u.authorized == true end)
      |> Enum.filter(fn u -> u.t_enabled == true and u.r_enabled == false end)
      |> Enum.map(fn u ->
        {"#{u.location} (#{u.public_key_identifier})", u.public_key_identifier}
      end)

    [{"Escolha um Transmissor", nil} | units]
  end

  defp count_transmissions(list) do
    list
    |> Enum.filter(fn t -> t.status == "T - PROCESSING" or t.status == "R - PROCESSING" end)
    |> IO.inspect
    |> length()
  end

  defp count_online_units() do
    Entities.list_units()
    |> Enum.filter(fn u -> u.authorized == true and u.status == true end)
    |> length()
  end

  defp count_offline_units() do
    Entities.list_units()
    |> Enum.filter(fn u -> u.authorized == true and u.status == false end)
    |> length()
  end

  defp count_pending_units() do
    Entities.list_units()
    |> Enum.filter(fn u -> u.authorized == false and u.status == true end)
    |> length()
  end

  defp get_volumes_by_origin() do
    "-"
  end

  defp get_volumes_by_origin(origin) do
    total_size =
      Operation.list_transmissions(:by_origin, origin)
      |> Enum.filter(fn t -> t.status == "R - OK" end)
      |> Enum.map(fn t -> t.size end)
      |> Enum.sum()

    "#{total_size} bytes"
  end

  defp count_transmissions_by_uploader() do
    "-"
  end

  defp count_transmissions_by_uploader(origin) do
    Operation.list_transmissions(:by_origin, origin)
    |> Enum.filter(fn t -> t.status == "R - OK" end)
    |> length()
  end

  defp get_average_transmission_time(origin) do
    # List transmissions
    transmissions =
      Operation.list_transmissions(:by_origin, origin)
      # Filter transmissions with no time = null values
      |> Enum.filter(fn t -> t.start != nil and t.end != nil end)

    # Return the transmissions length
    transmissions_length =
      transmissions
      |> length()

    # Return the sum of the difference between the begin and the end of the transmission
    total_transmission_time =
      Enum.map(transmissions, fn t -> DateTime.to_unix(t.end) - DateTime.to_unix(t.start) end)
      |> Enum.sum()

    if transmissions_length != 0 do
      if Float.round(total_transmission_time / transmissions_length, 2) > 120 do
        "+2min"
      else
        "#{Float.round(total_transmission_time / transmissions_length, 2)}s"
      end
    else
      "N/A"
    end
  end

  defp get_average_transmission_time() do
    # List transmissions
    transmissions =
      Operation.list_transmissions()
      # Filter transmissions with no time = null values
      |> Enum.filter(fn t -> t.start != nil and t.end != nil end)

    # Return the transmissions length
    transmissions_length =
      transmissions
      |> length()

    # Return the sum of the difference between the begin and the end of the transmission
    total_transmission_time =
      Enum.map(transmissions, fn t -> DateTime.to_unix(t.end) - DateTime.to_unix(t.start) end)
      |> Enum.sum()

    if transmissions_length != 0 do
      if Float.round(total_transmission_time / transmissions_length, 2) > 120 do
        "+2min"
      else
        "#{Float.round(total_transmission_time / transmissions_length, 2)}s"
      end
    else
      "N/A"
    end
  end
end

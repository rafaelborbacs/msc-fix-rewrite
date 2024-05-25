defmodule UploaderGWeb.TransmissionLive.Show do
  use UploaderGWeb, :live_view

  alias UploaderG.Operation

  alias UploaderG.Logging

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:transmission, Operation.get_transmission!(id))
     |> assign(:logs, list_logs(id, :by_transmission))}
  end

  def list_logs(transmission_id, :by_transmission) do
    Logging.list_logs(transmission_id, :by_transmission)
  end

  defp format_date(%DateTime{} = date) do
    Calendar.strftime(date, "%d/%m/%y às %H:%M:%S")
  end

  defp format_date(nil) do
    "—"
  end

  defp li_status(assigns) do
    case assigns.status do
      "T - OK" ->
        ~H"""
        <nobr class="text-blue-800 font-bold"><%= @status %></nobr>
        """

      "T - ERROR" ->
        ~H"""
        <nobr class="text-red-600 "><%= @status %></nobr>
        """

      _ ->
        ~H"""
        <nobr>—</nobr>
        """
    end
  end

  defp page_title(:show), do: "Detalhes da Transmissão"
  defp page_title(:edit), do: "Edit Transmission"

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
end

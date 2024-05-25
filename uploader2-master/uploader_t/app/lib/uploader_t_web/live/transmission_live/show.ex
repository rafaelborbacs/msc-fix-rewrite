defmodule UploaderTWeb.TransmissionLive.Show do
  use UploaderTWeb, :live_view

  alias UploaderT.Operation

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:transmission, Operation.get_transmission!(id))}
  end

  defp page_title(:show), do: "Show Transmission"
end

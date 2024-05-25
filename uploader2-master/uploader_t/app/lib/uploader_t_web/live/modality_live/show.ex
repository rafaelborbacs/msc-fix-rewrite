defmodule UploaderTWeb.ModalityLive.Show do
  use UploaderTWeb, :live_view

  alias UploaderT.CRUD

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:modality, CRUD.get_modality!(id))}
  end

  defp page_title(:show), do: "Detalhes da Modalidade"
  defp page_title(:edit), do: "Editar Modalidade"
end

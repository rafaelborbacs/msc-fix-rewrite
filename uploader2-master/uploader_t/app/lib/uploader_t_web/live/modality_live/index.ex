defmodule UploaderTWeb.ModalityLive.Index do
  use UploaderTWeb, :live_view

  alias UploaderT.CRUD
  alias UploaderT.CRUD.Modality

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :modalities, list_modalities())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Editar Modalidade")
    |> assign(:modality, CRUD.get_modality!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "Nova Modalidade")
    |> assign(:modality, %Modality{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Modalidades")
    |> assign(:modality, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    modality = CRUD.get_modality!(id)
    {:ok, _} = CRUD.delete_modality(modality)

    {:noreply, assign(socket, :modalities, list_modalities())}
  end

  defp list_modalities do
    CRUD.list_modalities()
  end
end

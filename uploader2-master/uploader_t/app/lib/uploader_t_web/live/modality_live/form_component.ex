defmodule UploaderTWeb.ModalityLive.FormComponent do
  use UploaderTWeb, :live_component

  alias UploaderT.CRUD

  @impl true
  def update(%{modality: modality} = assigns, socket) do
    changeset = CRUD.change_modality(modality)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"modality" => modality_params}, socket) do
    changeset =
      socket.assigns.modality
      |> CRUD.change_modality(modality_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"modality" => modality_params}, socket) do
    save_modality(socket, socket.assigns.action, modality_params)
  end

  defp save_modality(socket, :edit, modality_params) do
    case CRUD.update_modality(socket.assigns.modality, modality_params) do
      {:ok, _modality} ->
        {:noreply,
         socket
         |> put_flash(:info, "Modality updated successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_modality(socket, :new, modality_params) do
    case CRUD.create_modality(modality_params) do
      {:ok, _modality} ->
        {:noreply,
         socket
         |> put_flash(:info, "Modality created successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end

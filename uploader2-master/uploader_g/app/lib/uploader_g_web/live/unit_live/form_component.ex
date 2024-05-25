defmodule UploaderGWeb.UnitLive.FormComponent do
  use UploaderGWeb, :live_component

  alias UploaderG.Entities

  @impl true
  def update(%{unit: unit} = assigns, socket) do
    changeset = Entities.change_unit(unit)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"unit" => unit_params}, socket) do
    changeset =
      socket.assigns.unit
      |> Entities.change_unit(unit_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"unit" => unit_params}, socket) do
    save_unit(socket, socket.assigns.action, unit_params)
  end

  defp save_unit(socket, :edit, unit_params) do
    case Entities.update_unit(socket.assigns.unit, unit_params) do
      {:ok, _unit} ->
        {:noreply,
         socket
         |> put_flash(:info, "Unit updated successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_unit(socket, :new, unit_params) do
    case Entities.create_unit(unit_params) do
      {:ok, _unit} ->
        {:noreply,
         socket
         |> put_flash(:info, "Unit created successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end

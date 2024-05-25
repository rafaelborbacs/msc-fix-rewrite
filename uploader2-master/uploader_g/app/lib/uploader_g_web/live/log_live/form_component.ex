defmodule UploaderGWeb.LogLive.FormComponent do
  use UploaderGWeb, :live_component

  alias UploaderG.Logging

  @impl true
  def update(%{log: log} = assigns, socket) do
    changeset = Logging.change_log(log)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"log" => log_params}, socket) do
    changeset =
      socket.assigns.log
      |> Logging.change_log(log_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"log" => log_params}, socket) do
    save_log(socket, socket.assigns.action, log_params)
  end

  defp save_log(socket, :edit, log_params) do
    case Logging.update_log(socket.assigns.log, log_params) do
      {:ok, _log} ->
        {:noreply,
         socket
         |> put_flash(:info, "Log updated successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_log(socket, :new, log_params) do
    case Logging.create_log(log_params) do
      {:ok, _log} ->
        {:noreply,
         socket
         |> put_flash(:info, "Log created successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end

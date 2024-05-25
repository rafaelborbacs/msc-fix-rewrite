defmodule UploaderTWeb.DestinationLive.FormComponent do
  use UploaderTWeb, :live_component

  alias UploaderT.Config

  alias UploaderT.Config.DestinationConfig

  alias UploaderT.SSH

  def mount(socket) do
    {:ok, socket}
  end

  def update(%{config_data: config_data} = assigns, socket) do
    # Creates a new changeset
    changeset = Config.change_destination_config(config_data)

    {:ok,
     socket
     # merges the socket and the assigns
     |> assign(assigns)
     # set the changeset
     |> assign(:changeset, changeset)}
  end

  def handle_event("validate", %{"destination_config" => params}, socket) do
    changeset =
      %DestinationConfig{}
      # Generates new Changeset
      |> Config.change_destination_config(params)
      # Changes form behavior
      |> Map.put(:action, :insert)

    {:noreply, assign(socket, changeset: changeset)}
  end

  def handle_event("save", %{"destination_config" => params}, socket) do
    save_destination_config(socket, socket.assigns.action, params)
  end

  defp save_destination_config(socket, :index, destination_config_params) do
    case Config.update_destination_config(socket.assigns.config_data, destination_config_params) do
      {:ok, destination_config} ->
        Config.publish_destination_config()

        {
          :noreply,
          socket
          |> put_flash(:info, "Destination Config updated successfully")
        }

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end
end

defmodule UploaderTWeb.SourceLive.FormComponent do
  use UploaderTWeb, :live_component

  alias UploaderT.Config

  alias UploaderT.Config.SourceConfig

  alias UploaderT.StoreSCP

  def mount(socket) do
    {:ok, socket}
  end

  def update(%{config_data: config_data} = assigns, socket) do
    # Creates a new changeset
    changeset = Config.change_source_config(config_data)

    {:ok,
     socket
     # merges the socket and the assigns
     |> assign(assigns)
     # set the changeset
     |> assign(:changeset, changeset)}
  end

  def handle_event("validate", %{"source_config" => params}, socket) do
    changeset =
      %SourceConfig{}
      # Generates new Changeset
      |> Config.change_source_config(params)
      # Changes form behavior
      |> Map.put(:action, :insert)

    {:noreply, assign(socket, changeset: changeset)}
  end

  def handle_event("save", %{"source_config" => params}, socket) do
    save_source_config(socket, socket.assigns.action, params)
  end

  defp save_source_config(socket, :index, source_config_params) do
    case Config.update_source_config(socket.assigns.config_data, source_config_params) do
      {:ok, _source_config} ->
        Config.publish_source_config()

        StoreSCP.restart()

        {
          :noreply,
          socket
          |> put_flash(:info, "Source Config updated successfully")
        }

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end
end

defmodule UploaderRWeb.SelfLive.FormComponent do
  use UploaderRWeb, :live_component

  alias UploaderR.Config

  alias UploaderR.Config.SelfConfig

  alias UploaderR.SSH

  alias UploaderR.StoreSCP

  def mount(socket) do
    {:ok, socket}
  end

  def update(%{config_data: config_data} = assigns, socket) do
    # Creates a new changeset
    changeset = Config.change_self_config(config_data)

    {:ok,
     socket
     # merges the socket and the assigns
     |> assign(assigns)
     # set the changeset
     |> assign(:changeset, changeset)}
  end

  def handle_event("validate", %{"self_config" => params}, socket) do
    changeset =
      %SelfConfig{}
      # Generates new Changeset
      |> Config.change_self_config(params)
      # Changes form behavior
      |> Map.put(:action, :insert)

    {:noreply, assign(socket, changeset: changeset)}
  end

  def handle_event("save", %{"self_config" => params}, socket) do
    IO.inspect(SSH.identifier(:self))
    save_self_config(socket, socket.assigns.action, params)
    Config.publish_config()
    {:noreply, socket}
  end

  defp save_self_config(socket, :index, self_config_params) do
    case Config.update_self_config(socket.assigns.config_data, self_config_params) do
      {:ok, _self_config} ->

        StoreSCP.restart()

        {:noreply,
         socket
         |> put_flash(:info, "Self Config updated successfully")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end
end

defmodule UploaderTWeb.DestinationLive.Index do
  use UploaderTWeb, :live_view

  alias UploaderT.Config
  alias UploaderT.Config.DestinationConfig

  @impl true
  def mount(_params, _session, socket) do
    changeset = Config.get_destination_config!()

    {
      :ok,
      socket
      |> assign(:config_data, changeset)
      |> assign(:page_title, "Destino")
    }
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :index, _params) do
    socket
  end

  defp apply_action(socket, :edit, _params) do
    socket
  end
end

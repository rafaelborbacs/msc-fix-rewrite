defmodule UploaderTWeb.SourceLive.Index do
  use UploaderTWeb, :live_view

  alias UploaderT.Config
  alias UploaderT.Config.SourceConfig
  alias UploaderT.SSH

  @impl true
  def mount(_params, _session, socket) do
    changeset = Config.get_source_config!()

    {
      :ok,
      socket
      |> assign(:config_data, changeset)
      |> assign(:page_title, "Origem")
    }
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  def origin_uuid() do
    SSH.identifier(:self)
  end

  defp apply_action(socket, :index, _params) do
    socket
  end

  defp apply_action(socket, :edit, _params) do
    socket
  end
end

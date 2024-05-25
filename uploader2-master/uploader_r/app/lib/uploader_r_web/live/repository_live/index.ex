defmodule UploaderRWeb.RepositoryLive.Index do
  use UploaderRWeb, :live_view

  alias UploaderR.Config
  alias UploaderR.Config.SelfConfig
  alias UploaderR.SSH

  @impl true
  def mount(_params, _session, socket) do
    changeset = Config.get_self_config!()

    {
      :ok,
      socket
      |> assign(:config_data, changeset)
      |> assign(:uuid, SSH.identifier(:self))
      |> assign(:page_title, "Configurando Repositório")
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

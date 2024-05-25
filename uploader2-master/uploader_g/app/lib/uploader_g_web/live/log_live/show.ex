defmodule UploaderGWeb.LogLive.Show do
  use UploaderGWeb, :live_view

  alias UploaderG.Logging
  alias UploaderG.SSH

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:log, Logging.get_log!(id))}
  end

  defp format_date(%DateTime{} = date) do
    Calendar.strftime(date, "%d/%m/%y às %H:%M:%S")
  end

  defp page_title(:show), do: "Mostrar Log"
  defp page_title(:edit), do: "Editar Log"

  defp origin_uuid(origin), do: SSH.identifier(:public_key, origin)
end

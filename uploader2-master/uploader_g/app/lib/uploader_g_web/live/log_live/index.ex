defmodule UploaderGWeb.LogLive.Index do
  use UploaderGWeb, :live_view

  alias UploaderG.Entities

  alias UploaderG.Logging
  alias UploaderG.Logging.Log
  alias UploaderG.Entities
  alias Phoenix.PubSub
  # topic is the topic name which our live view process will subcribe to
  @topic "log:arrived"

  @impl true
  def mount(_params, _session, socket) do
    # Subscribes to the @topic
    Phoenix.PubSub.subscribe(UploaderG.PubSub, @topic)

    {
      :ok,
      socket
      |> assign(
        :logs,
        list_logs()
      )
      |> assign(:current_origin, "Escolha uma unidade")
      # |> assign(:units, list_units(:authorized))
    }
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Editar Log")
    |> assign(:log, Logging.get_log!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "Novo Log")
    |> assign(:log, %Log{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Todos os Logs")
    |> assign(:log, nil)
  end

  defp apply_action(socket, :list_error, _params) do
    socket
    |> assign(:page_title, "Logs de Erro")
    |> assign(:logs, list_logs(:error))
  end

  defp apply_action(socket, :list_info, _params) do
    socket
    |> assign(:page_title, "Logs (Excluindo Erros)")
    |> assign(:logs, list_logs(:info))
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    log = Logging.get_log!(id)
    {:ok, _} = Logging.delete_log(log)

    {:noreply, assign(socket, :logs, list_logs())}
  end

  # Handles the event of a new log being published
  def handle_info({:log_arrived, log}, socket) do
    {:noreply, assign(socket, :logs, [log | socket.assigns.logs])}
  end

  defp get_unit_by_key(nil) do
    "—"
  end

  defp get_unit_by_key(key) do
    unit = Entities.get_unit(key, :by_public_key)

    if unit do
      unit.location
    else
      "—"
    end
  end

  defp format_date(%DateTime{} = date) do
    Calendar.strftime(date, "%d/%m/%y às %H:%M:%S")
  end

  defp format_date(nil) do
    "—"
  end

  defp list_logs do
    Logging.list_logs()
  end

  defp list_logs(:error) do
    Logging.list_logs(:error)
  end

  defp list_logs(:info) do
    Logging.list_logs(:info)
  end

end

defmodule UploaderTWeb.TransmissionLive.Index do
  use UploaderTWeb, :live_view

  alias UploaderT.Operation
  alias UploaderT.Operation.Transmission
  alias Phoenix.PubSub

  @impl true
  def mount(_params, _session, socket) do
    {
      :ok,
      socket
      |> assign(
        :transmissions,
        list_transmissions()
      )
      |> assign(:current_page, 1)
      |> assign(:total_pages, total_pages(list_transmissions()))
      |> assign(:studies_data, list_transmissions(:studies_data))
    }
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Transmissões")
    |> assign(:transmission, nil)
  end

  @impl true
  def handle_event("retry", %{"id" => id}, socket) do
    struct = Operation.get_transmission!(id)

    PubSub.broadcast(
      UploaderT.PubSub,
      "retry:transmission",
      {:retry_transmission, struct}
    )

    {
      :noreply,
      socket
    }
  end

  defp study_instance_uid_of(:study_data, {study_instance_uid, study_description}) do
    study_instance_uid
  end

  defp study_description_of(:study_data, {study_instance_uid, study_description}) do
    study_description
  end

  defp list_transmissions do
    Operation.list_transmissions()
  end

  defp filter_transmissions(
         :of_study_data,
         {study_instance_uid, study_description},
         transmissions
       ) do
    transmissions
    |> Enum.filter(fn t -> t.study_instance_uid == study_instance_uid end)
  end

  defp list_transmissions(:studies_data) do
    Operation.list_transmissions()
    |> Enum.map(fn t -> {t.study_instance_uid, t.study_description} end)
    |> Enum.uniq()
  end

  defp total_pages(list) do
    if length(list) == 0 do
      1
    else
      whole_pages = div(length(list), 10)
      remanecent_page = if Integer.mod(length(list), 10) == 0, do: 0, else: 1
      whole_pages + remanecent_page
    end
  end
end

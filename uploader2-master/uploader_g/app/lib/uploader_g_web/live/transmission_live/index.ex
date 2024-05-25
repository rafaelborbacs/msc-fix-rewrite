defmodule UploaderGWeb.TransmissionLive.Index do
  use UploaderGWeb, :live_view

  alias UploaderG.MQTT

  alias UploaderG.Operation
  alias UploaderG.Operation.Transmission
  alias UploaderG.Entities
  alias Phoenix.PubSub

  # topic is the topic name which our live view process will subcribe to
  @topic_transmission_created "transmission:created"
  @topic_transmission_updated "transmission:updated"

  @impl true
  def mount(_params, _session, socket) do
    Phoenix.PubSub.subscribe(UploaderG.PubSub, @topic_transmission_created)
    Phoenix.PubSub.subscribe(UploaderG.PubSub, @topic_transmission_updated)

    {
      :ok,
      socket
      |> assign(:current_page, 1)
      # |> assign(:total_pages, total_pages(list_transmissions()))
      |> assign(:transmissions, list_transmissions(:stale_is_error))
      |> list_transmissions(:studies_data)
      # |> IO.inspect()
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
  def handle_event("delete", %{"id" => id}, socket) do
    transmission = Operation.get_transmission!(id)
    {:ok, _} = Operation.delete_transmission(transmission)

    {:noreply, assign(socket, :transmissions, list_transmissions())}
  end

  @impl true
  def handle_event("retry", %{"id" => id}, socket) do
    transmission = Operation.get_transmission!(id)

    origin = Entities.get_unit(transmission.origin, :by_public_key_identifier)

    MQTT.publish(
      "G/retry/T/#{origin.public_key_identifier}/transmission/#{transmission.uuid}",
      Jason.encode!(%{
        uuid: transmission.uuid
      })
    )

    {:noreply, socket}
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

  defp list_transmissions do
    Operation.list_transmissions()
  end

  defp list_transmissions(:stale_is_error) do
    Operation.list_transmissions()
  end

  defp list_transmissions(socket, :studies_data) do
    studies_data =
      socket.assigns.transmissions
      |> Enum.map(fn t -> {t.study_instance_uid, t.study_description} end)
      |> Enum.uniq()
      |> IO.inspect()

    assign(socket, :studies_data, studies_data)
  end

  defp list_transmissions(:of_study_data, {study_instance_uid, study_description}) do
    Operation.list_transmissions()
    |> Enum.filter(fn t -> t.study_instance_uid == study_instance_uid end)
  end

  defp list_study_data(transmissions) do
    transmissions
    |> Enum.map(fn t -> {t.study_instance_uid, t.study_description} end)
    |> Enum.uniq()
  end

  defp filter_transmissions(
         :of_study_data,
         {study_instance_uid, study_description},
         transmissions
       ) do
    transmissions
    |> Enum.filter(fn t -> t.study_instance_uid == study_instance_uid end)
  end

  defp study_instance_uid_of(:study_data, {study_instance_uid, study_description}) do
    study_instance_uid
  end

  defp study_description_of(:study_data, {study_instance_uid, study_description}) do
    study_description
  end

  defp processing_count_of(:study_data, {study_instance_uid, study_description}, transmissions) do
    transmissions
    |> Enum.filter(fn t ->
      (t.study_instance_uid == study_instance_uid and t.status == "T - PROCESSING") or
      (t.study_instance_uid == study_instance_uid and t.status == "R - PROCESSING")
    end)
    |> Enum.count()
  end

  defp error_count_of(:study_data, {study_instance_uid, study_description}, transmissions) do
    transmissions
    |> Enum.filter(fn t ->
      (t.study_instance_uid == study_instance_uid and t.status == "T - ERROR") or
      (t.study_instance_uid == study_instance_uid and t.status == "R - ERROR")
    end)
    |> IO.inspect()
    |> Enum.count()
  end

  defp ok_count_of(:study_data, {study_instance_uid, study_description}, transmissions) do
    transmissions
    |> Enum.filter(fn t -> t.study_instance_uid == study_instance_uid and t.status == "R - OK" end)
    |> Enum.count()
  end

  defp sync_count_of(:study_data, {study_instance_uid, study_description}, transmissions) do
    transmissions
    |> Enum.filter(fn t ->
      (t.study_instance_uid == study_instance_uid and t.status == "T - SYNC") or
      (t.study_instance_uid == study_instance_uid and t.status == "R - STORE")
    end)
    |> Enum.count()
  end

  defp slice_page(list, current_page) do
    Enum.slice(list, 1 + (current_page - 1) * 10, 10)
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

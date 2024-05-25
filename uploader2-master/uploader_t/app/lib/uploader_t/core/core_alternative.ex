defmodule UploaderT.CoreAlternative do
  use GenServer

  alias UploaderT.Core.Compressor

  alias UploaderT.Core.Encrypter

  alias UploaderT.Core.Deleter

  alias UploaderT.Core.Sync

  alias UploaderT.Core.Logger

  alias UploaderT.Config

  alias UploaderT.Core.DicomInspector

  alias UploaderT.Core.AllowLister

  alias UploaderT.Operation

  alias Phoenix.PubSub

  @trigger_count 3

  @topic_retry_transmission "retry:transmission"

  @topic_delete_transmission "delete:transmission"

  def start_link(args) do
    GenServer.start_link(__MODULE__, args)
  end

  def init(args) do
    {:ok, watcher_pid} = FileSystem.start_link(args)
    result = FileSystem.subscribe(watcher_pid)
    Phoenix.PubSub.subscribe(UploaderT.PubSub, @topic_retry_transmission)
    Phoenix.PubSub.subscribe(UploaderT.PubSub, @topic_delete_transmission)
    {:ok, %{watcher_pid: watcher_pid, queue_size: 0, rsyncing: false}}
  end

  def handle_info({:file_event, watcher_pid, {path, events}}, %{watcher_pid: watcher_pid, queue_size: previous_queue_size, rsyncing: rsyncing} = state) do
    # If the file event is the :closed event, then we need to upload the corresponding file
    if Enum.member?(events, :closed) do
      IO.inspect("#{previous_queue_size + 1}/#{(@trigger_count)}")
      Task.Supervisor.async_nolink(MyApp.TaskSupervisor, fn -> prepare(path) end)
      if previous_queue_size + 1 >= (@trigger_count) and rsyncing == false do
        destination_config = Config.get_destination_config!()
        source_config = Config.get_source_config!()
        Task.Supervisor.async_nolink(MyApp.TaskSupervisor, fn -> Sync.synchronize(
          :folder,
          {"uploader_t_1", destination_config.ip, destination_config.port, "/home/uploader_t_1"},
          source_config.limit
        ) end)

        {:noreply, %{watcher_pid: watcher_pid, queue_size: 0, rsyncing: true}}
      else
        {:noreply, %{watcher_pid: watcher_pid, queue_size: previous_queue_size + 1, rsyncing: rsyncing}}
      end
    else
      # The state is unchanged.
      {:noreply, state}
    end

  end

  def handle_info({:file_event, watcher_pid, :stop}, %{watcher_pid: watcher_pid} = state) do
    # Logger.log(:file_watcher_stopped)
    # The state is unchanged.
    {:noreply, state}
  end

  def handle_info({pid, {:error, :synchronize, code}}, %{watcher_pid: watcher_pid, queue_size: previous_queue_size, rsyncing: rsyncing} = state) do
    IO.inspect("Error while synchronizing: #{code}")
    if rsyncing == false do
      IO.inspect("At the ending of a synchronization, the rsyncing flag was false. which is inconsistent state")
    end
    # Set the rsyncing flag to false.
    {:noreply, %{watcher_pid: watcher_pid, queue_size: 0, rsyncing: false}}
  end

  def handle_info({pid, {:ok, :synchronize}}, %{watcher_pid: watcher_pid, queue_size: previous_queue_size, rsyncing: rsyncing} = state) do
    IO.inspect("Synchronization completed")
    if rsyncing == false do
      IO.inspect("At the ending of a synchronization, the rsyncing flag was false. which is inconsistent state")
    end
    # Set the rsyncing flag to false.
    {:noreply, %{watcher_pid: watcher_pid, queue_size: 0, rsyncing: false}}
  end

  # The task was sucessful
  def handle_info({ref, answer}, %{ref: ref} = state) do
    # We don't care about the DOWN message now, so let's demonitor and flush it
    Process.demonitor(ref, [:flush])
    # Do something with the result and then return
    {:noreply, %{state | ref: nil}}
  end

  # The task failed
  def handle_info({:DOWN, ref, :process, pid, :normal}, state) do
    # Log and possibly restart the task...
    {:noreply, state}
  end

  def handle_info({:retry_transmission, transmission}, socket) do
    Task.Supervisor.async_nolink(MyApp.TaskSupervisor, fn -> prepare(transmission, :retry) end)

    {
      :noreply,
      socket
    }
  end

  def handle_info({:delete_transmission, transmission}, socket) do
    Deleter.delete(transmission.file_path)
    Operation.delete_transmission(transmission)

    {
      :noreply,
      socket
    }
  end

  def handle_info(unknown_message, state) do
    IO.inspect("An unknown message was caught by an all-catch clause on #{__MODULE__}")
    IO.inspect("The unkwon_message was:")
    IO.inspect(unknown_message)
    IO.inspect("The state of this process at such moment was:")
    IO.inspect(state)

    {:noreply, state}
  end

  defp prepare(transmission, :retry) do
    # path to the file to be retransmitted
    file_path = transmission.file_path

    # Get the destination config from the configuration file
    destination_config = Config.get_destination_config!()

    # the file was encrypted and compressed before the down
    if String.contains?(file_path, ".gpg") and String.contains?(file_path, ".zip") do
      # so, we can already send it to the destination
      result =
        Sync.synchronize(
          file_path,
          {"uploader_t_1", destination_config.ip, destination_config.port, "/home/uploader_t_1"}
        )

      if result == {:ok, :synchronize} do
        Logger.log(:end_transmission, %{uuid: transmission.uuid})
        Operation.delete_transmission(transmission)
        # Since R - OK is the actual success state, we do not delete the file here.
        # Deleter.delete(encrypted_file_path)
        # Deleter.delete(file_path)
        {:ok, :transmission_succeeded, result}
      else
        Logger.log(:error_transmission, %{uuid: transmission.uuid})
        {:error, :transmission_failed, :sync_error}
      end
    end
  end

  defp prepare(input_path) do
    # Extract the AE Title of the Modality
    {:ok, ae_title} = DicomInspector.inspect(:ae_title, input_path)
    {:ok, study_instance_uid} = DicomInspector.inspect(:study_instance_uid, input_path)
    {:ok, study_description} = DicomInspector.inspect(:study_description, input_path)

    # If the AE Title is not in the list of allowed AEs, then we don't upload the file
    if AllowLister.allowed?(:ae_title, ae_title) do
      # Get the source, destination config from the configuration file
      destination_config = Config.get_destination_config!()

      source_config = Config.get_source_config!()

      # Generate an UUID for this transmission
      uuid = Ecto.UUID.bingenerate() |> Base.encode16()

      file_path =
        input_path
        |> String.split("/")
        |> List.delete_at(-1)
        |> List.insert_at(-1, uuid)
        |> Enum.join("/")

      # rename the file to the UUID
      File.rename!(
        input_path,
        file_path
      )

      # Log the start of the transmission
      Logger.log(:start_transmission, %{
        size: File.stat!(file_path).size,
        checksum: compute_checksum(file_path),
        uuid: uuid,
        study_instance_uid: study_instance_uid,
        study_description: study_description
      })

      # Log the start of the compression
      # Logger.log({:transmission, :start_compression}, uuid)

      # Compress the file
      compressed_file_path = Compressor.compress(file_path)
      # Once the file is compressed, we can delete the original file
      Deleter.delete(file_path)

      # Log the end of the compression
      # Logger.log({:transmission, :end_compression}, uuid)

      # Log the start of the encryption
      # Logger.log({:transmission, :start_encryption}, uuid)

      # Encrypt the file
      encrypted_file_path = Encrypter.encrypt(compressed_file_path)

      # Once the file is encrypted, we can delete the compressed file
      Deleter.delete(compressed_file_path)

      # Log the end of the encryption
      # Logger.log({:transmission, :end_encryption}, uuid)

      {:ok, struct} =
        Operation.create_transmission(%{
          file_path: encrypted_file_path,
          sent: true,
          uuid: uuid,
          study_instance_uid: study_instance_uid,
          study_description: study_description
        })

      # Log the start of the sync
      # Logger.log({:transmission, :start_sync}, uuid)

      # # Synchronize the file to the destination
      # result =
      #   Sync.synchronize(
      #     encrypted_file_path,
      #     {"uploader_t_1", destination_config.ip, destination_config.port, "/home/uploader_t_1"},
      #     source_config.limit
      #   )

      # # Once the file is synchronized, we can delete the encrypted file
      # IO.inspect("encrypted_file_path value: #{encrypted_file_path}")

      # if result == {:ok, :synchronize} do
      #   Logger.log(:end_transmission, %{uuid: uuid})
      #   Logger.log({:transmission, :end_sync}, uuid)
      #   # Since R - OK is the actual success state, we do not delete the file here.
      #   # Operation.delete_transmission(struct)
      #   # Deleter.delete(encrypted_file_path)
      #   {:ok, :transmission_succeeded, result}
      # else
      #   Logger.log(:error_transmission, %{uuid: uuid})
      #   Logger.log({:transmission, :error_sync}, uuid)
      #   {:error, :transmission_failed, :sync_error}
      # end
    else
      # Since the file is not on the list of allowed AEs, we don't upload it
      # So, we delete it
      Deleter.delete(input_path)
      # Logger.log({:transmission, :forbidden})
      {:error, :transmission_failed, :forbidden}
    end
  end

  defp compute_checksum(file_name) do
    # Open the file, get it's contents
    file_contents = File.read!(file_name)
    # use the checksum library to compute the checksum
    :crypto.hash(:md5, file_contents) |> Base.encode16()
  end
end

defmodule UploaderT.CoreList do
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

  @topic_retry_transmission "retry:transmission"

  @topic_delete_transmission "delete:transmission"

  def start_link(args) do
    GenServer.start_link(__MODULE__, args)
  end

  def init(args) do
    IO.inspect("Initializing UploaderT.CoreList")
    # Start the FileSystem process
    {:ok, watcher_pid} = FileSystem.start_link(args)
    # Makes the FileSystem process send messages to this watcher
    FileSystem.subscribe(watcher_pid)

    Phoenix.PubSub.subscribe(UploaderT.PubSub, @topic_retry_transmission)
    Phoenix.PubSub.subscribe(UploaderT.PubSub, @topic_delete_transmission)

    # Get the list of files in the directory
    files = case File.ls("observable") do
      {:ok, files} ->
        files_refined = Enum.map(files, fn last_name -> {"observable/" <> last_name, :pending} end)

        Operation.retain_transmissions(files_refined |> Enum.map(fn {file, _} -> file end))

        files_refined
      {:error, reason} ->
        IO.inspect("Error: #{reason}")
        []
    end

    # If there is a file in the directory, start the task
    if length(files) > 0 do
      starting_path = files |> List.first |> elem(0)
      # starting_transmission_uuid = files |> List.first |> elem(2)
      Task.Supervisor.async_nolink(MyApp.TaskSupervisor, fn -> upload(starting_path) end)

      {
        :ok,
        %{
          watcher_pid: watcher_pid,
          files: files,
          current_file: files |> List.first
          }
      }
    else
      {:ok, %{watcher_pid: watcher_pid, files: files, current_file: nil}}
    end

  end

  def handle_info({:file_event, watcher_pid, {path, events}}, %{watcher_pid: watcher_pid, files: files, current_file: current} = state) do
    # IO.inspect(state)
    IO.inspect({path, events})
    # IO.inspect({:file_event, path, events})
    # :moved_to events add new tuples to the state
    # :deleted events trigger list updates removing the file from the list

    files_updated = cond do
      Enum.member?(events, :closed) and !String.contains?(path, ".gitignore")  ->
        # Get the transmission_uuid from the path
        # transmission_uuid =
        #   extract_transmission_uuid(path)

        IO.inspect("Find :closed event")

        [{path, :pending} | files]

      # Enum.member?(events, :deleted) and !String.contains?(path, ".gitignore") and String.ends_with?(path, ".zip.gpg") ->

      #   IO.inspect("Find :deleted event:")

      #   IO.inspect({path, events})

      #   IO.inspect("-----------------------------------------------------------------")

      #   # Get the transmission_uuid from the path
      #   transmission_uuid =
      #     extract_transmission_uuid(path)

      #   # Remove the file from the list
      #   Enum.filter(files, fn {path, status} -> transmission_uuid != transmission_uuid end)

      # {:noreply, %{state | files: updated_files}}

      true ->
        files
    end

    # If there is no current file, start the task with the first pending file in the list
    if current == nil do
      first_pending_file = Enum.find(files_updated, fn {path, status} -> status == :pending end)
      if first_pending_file != nil do
        {path, status} = first_pending_file
        Task.Supervisor.async_nolink(MyApp.TaskSupervisor, fn -> upload(path) end)
        {:noreply, %{state | files: files_updated, current_file: first_pending_file}}
      else
        # There is no file to store, at all
        {:noreply, %{state | files: files_updated, current_file: nil}}
      end
    else
      # The list is updated with the new data, but the current file is not changed
      {:noreply, %{state | files: files_updated}}
    end

  end

  def handle_info({:file_event, watcher_pid, :stop}, %{watcher_pid: watcher_pid} = state) do
    # Your own logic when monitor stop

    {:noreply, state}
  end

  def handle_info({pid, {:error, :store}}, %{watcher_pid: watcher_pid, files: files, current_file: current} = state) do
    IO.inspect("Error while storing file")
    # Make the updated entry with the new status based on the result of the upload
    updated_entry = {current |> elem(0), :pending}
    # Update the list of files with the updated entry
    updated_files = Enum.map(files, fn entry -> if entry == current, do: updated_entry, else: entry end)
    # Get the next file to upload
    next_file = updated_files |> Enum.find(fn entry -> entry |> elem(1) == :pending end)
    # If there is a next file to upload, start the upload
    if next_file != nil do
      Task.Supervisor.async_nolink(MyApp.TaskSupervisor, fn -> upload(next_file |> elem(0)) end)
      {:noreply, %{watcher_pid: watcher_pid, files: updated_files, current_file: next_file}}
    else
      {:noreply, %{watcher_pid: watcher_pid, files: updated_files, current_file: nil}}
    end

  end

  def handle_info({:delete_transmission, transmission}, socket) do
    Deleter.delete(transmission.file_path)
    Operation.delete_transmission(transmission)

    {
      :noreply,
      socket
    }
  end

  def handle_info({pid, {:ok, :store}}, %{watcher_pid: watcher_pid, files: files, current_file: current} = state) do
    IO.inspect("Synchronization completed")
    # Make the updated entry with the new status based on the result of the upload
    updated_entry = { current |> elem(0), :completed}
    # Update the list of files with the updated entry
    updated_files = files |> Enum.map(fn entry -> if entry |> elem(0) == current |> elem(0), do: updated_entry, else: entry end)
    # Get the next file to upload
    next_file = updated_files |> Enum.find(fn entry -> entry |> elem(1) == :pending end)
    IO.inspect("Next file:")
    IO.inspect(next_file)
    # If there is a next file to upload, start the upload process
    # If there is not a next file to upload, update the state with a nil current_file
    if next_file != nil do
      Task.Supervisor.async_nolink(MyApp.TaskSupervisor, fn ->  upload(next_file |> elem(0)) end)
      {:noreply, %{watcher_pid: watcher_pid, files: updated_files, current_file: next_file}}
    else
      {:noreply, %{watcher_pid: watcher_pid, files: updated_files, current_file: nil}}
    end
  end

  # The task was sucessful
  def handle_info({ref, answer}, %{watcher_pid: watcher_pid} = state) do
    # We don't care about the DOWN message now, so let's demonitor and flush it
    Process.demonitor(ref, [:flush])
    # Do something with the result and then return

    {:noreply, state}
  end

  # The task failed
  def handle_info({:DOWN, ref, :process, pid, :normal}, state) do
    # Log and possibly restart the task...

    {:noreply, state}
  end

  # The task failed
  def handle_info({:DOWN, ref, :process, pid, :normal, _}, state) do
    # Log and possibly restart the task...
    {:noreply, state}
  end

  # The task failed
  def handle_info({:DOWN, ref, :process, pid, reason, _}, state) do
    # Log and possibly restart the task...
    IO.inspect(reason)
    {:noreply, state}
  end

  # The task failed
  def handle_info({:DOWN, ref, :process, pid, {:error, code}}, state) do
    # Log and possibly restart the task...
    IO.inspect("Error:")
    IO.inspect({:error, code})
    {:noreply, state}
  end

  defp upload(input_path) do
    IO.inspect("Input Path: #{input_path}")

    # Extract the AE Title of the Modality
    {:ok, ae_title} = DicomInspector.inspect(:ae_title, input_path)
    # {:ok, study_instance_uid} = DicomInspector.inspect(:study_instance_uid, input_path)
    # {:ok, study_description} = DicomInspector.inspect(:study_description, input_path)

    study_instance_uid =
    case DicomInspector.inspect(:study_instance_uid, input_path) do
      {:ok, study_instance_uid} -> study_instance_uid
      {:error, _} -> "Unknown"
    end

    study_description =
    case DicomInspector.inspect(:study_description, input_path) do
      {:ok, study_description} -> study_description
      {:error, _} -> "Unknown"
    end

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

      # IO.inspect(Operation.count_transmissions)

      # Log the start of the sync
      # Logger.log({:transmission, :start_sync}, uuid)

      # Synchronize the file to the destination
      result =
        Sync.synchronize(
          encrypted_file_path,
          {"uploader_t_1", destination_config.ip, destination_config.port, "/home/uploader_t_1"},
          source_config.limit
        )

      # Once the file is synchronized, we can delete the encrypted file
      # IO.inspect("encrypted_file_path value: #{encrypted_file_path}")

      if result == {:ok, :synchronize} do
        Logger.log(:end_transmission, %{uuid: uuid})
        Logger.log({:transmission, :end_sync}, uuid)
        # Since R - OK is the actual success state, we do not delete the file here.
        # Operation.delete_transmission(struct)
        Deleter.delete(encrypted_file_path)
        # Deleter.delete(input_path)
        # {:ok, :transmission_succeeded, result}
        {:ok, :store}
      else
        Logger.log(:error_transmission, %{uuid: uuid})
        Logger.log({:transmission, :error_sync}, uuid)
        # {:error, :transmission_failed, :sync_error}
        {:error, :store}
      end
    else
      # Since the file is not on the list of allowed AEs, we don't upload it
      # So, we delete it
      Deleter.delete(input_path)
      # Logger.log({:transmission, :forbidden})
      # {:error, :transmission_failed, :forbidden}
      {:error, :store}
    end

  end

  # defp extract_transmission_uuid(path) do
  #   if !String.contains?(path, ".gitignore") and String.ends_with?(path, ".zip.gpg") do
  #     String.split(path, "/")
  #     |> List.last()
  #     |> String.replace(".zip", "")
  #     |> String.replace(".gpg", "")
  #   else
  #     nil
  #   end
  # end

  defp compute_checksum(file_name) do
    # Open the file, get it's contents
    file_contents = File.read!(file_name)
    # use the checksum library to compute the checksum
    :crypto.hash(:md5, file_contents) |> Base.encode16()
  end
end

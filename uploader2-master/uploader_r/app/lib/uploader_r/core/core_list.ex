defmodule UploaderR.CoreList do
  use GenServer

  alias UploaderR.Core.Decompressor

  alias UploaderR.Core.Decrypter

  alias UploaderR.Config

  alias UploaderR.Core.Deleter

  alias UploaderR.Core.Logger

  def start_link(args) do
    GenServer.start_link(__MODULE__, args)
  end

  def init(args) do
    # Start the FileSystem process
    {:ok, watcher_pid} = FileSystem.start_link(args)
    # Makes the FileSystem process send messages to this watcher
    FileSystem.subscribe(watcher_pid)

    # Get the list of files in the directory
    files = case File.ls("/home/uploader_t_1/encrypted/") do
      {:ok, files} ->
        Enum.map(files, fn last_name -> {"/home/uploader_t_1/encrypted/" <> last_name, :pending} end)
        |> Enum.map(fn {path, status} -> {path, status, extract_transmission_uuid(path)} end)
        |> Enum.filter(fn {path, status, transmission_uuid} -> transmission_uuid != nil end)
      {:error, reason} ->
        IO.inspect("Error: #{reason}")
        []
    end

    # If there is a file in the directory, start the task
    if length(files) > 0 do
      starting_path = files |> List.first |> elem(0)
      starting_transmission_uuid = files |> List.first |> elem(2)
      Task.Supervisor.async_nolink(MyApp.TaskSupervisor, fn -> upload(starting_path, starting_transmission_uuid) end)

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
    # IO.inspect({:file_event, path, events})
    # :moved_to events add new tuples to the state
    # :deleted events trigger list updates removing the file from the list

    files_updated = cond do
      Enum.member?(events, :moved_to) and !String.contains?(path, ".gitignore") and String.ends_with?(path, ".zip.gpg")  ->
        # Get the transmission_uuid from the path
        transmission_uuid =
          extract_transmission_uuid(path)

        IO.inspect("Find :moved_to event")

        [{path, :pending, transmission_uuid} | files]

      Enum.member?(events, :deleted) and !String.contains?(path, ".gitignore") and String.ends_with?(path, ".zip.gpg") ->

        IO.inspect("Find :deleted event:")

        IO.inspect({path, events})

        IO.inspect("-----------------------------------------------------------------")

        # Get the transmission_uuid from the path
        transmission_uuid =
          extract_transmission_uuid(path)

        # Remove the file from the list
        Enum.filter(files, fn {path, status, transmission_uuid} -> transmission_uuid != transmission_uuid end)

      # {:noreply, %{state | files: updated_files}}

      true ->
        files
    end

    # If there is no current file, start the task with the first pending file in the list
    if current == nil do
      first_pending_file = Enum.find(files_updated, fn {path, status, transmission_uuid} -> status == :pending end)
      if first_pending_file != nil do
        {path, status, transmission_uuid} = first_pending_file
        Task.Supervisor.async_nolink(MyApp.TaskSupervisor, fn -> upload(path, transmission_uuid) end)
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
    updated_entry = {current |> elem(0), :pending, current |> elem(2) }
    # Update the list of files with the updated entry
    updated_files = Enum.map(files, fn entry -> if entry == current, do: updated_entry, else: entry end)
    # Get the next file to upload
    next_file = updated_files |> Enum.find(fn entry -> entry |> elem(1) == :pending end)
    # If there is a next file to upload, start the upload
    if next_file != nil do
      Task.Supervisor.async_nolink(MyApp.TaskSupervisor, fn -> upload(next_file |> elem(0), next_file |> elem(2)) end)
      {:noreply, %{watcher_pid: watcher_pid, files: updated_files, current_file: next_file}}
    else
      {:noreply, %{watcher_pid: watcher_pid, files: updated_files, current_file: nil}}
    end

  end

  def handle_info({pid, {:ok, :store}}, %{watcher_pid: watcher_pid, files: files, current_file: current} = state) do
    IO.inspect("Synchronization completed")
    # Make the updated entry with the new status based on the result of the upload
    updated_entry = { current |> elem(0), :completed, current |> elem(1)}
    # Update the list of files with the updated entry
    updated_files = files |> Enum.map(fn entry -> if entry |> elem(0) == current |> elem(0), do: updated_entry, else: entry end)
    # Get the next file to upload
    next_file = updated_files |> Enum.find(fn entry -> entry |> elem(1) == :pending end)
    IO.inspect("Next file:")
    IO.inspect(next_file)
    # If there is a next file to upload, start the upload process
    # If there is not a next file to upload, update the state with a nil current_file
    if next_file != nil do
      Task.Supervisor.async_nolink(MyApp.TaskSupervisor, fn ->  upload(next_file |> elem(0), next_file |> elem(2)) end)
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

  defp upload(path, transmission_uuid) do

    # Get the repository config
    self_config = Config.get_self_config!()

    repository_host = self_config.host
    repository_port = self_config.port
    uploader_uuid = self_config.uuid
    repository_aetitle = self_config.repository_ae_title
    self_ae_title = if byte_size(self_config.self_ae_title) > 0, do: self_config.self_ae_title, else: "UPLOADER_R"

    # Log the start of the decryption
    # Logger.log({:transmission, :start_decryption}, transmission_uuid)

    Logger.log(:start_processing, transmission_uuid)
    # Decrypt and delete the encrypted file
    decrypted_file_path = Decrypter.decrypt(path)
    # Apparently, The decompressor implicitly deletes the file, so I'll comment this line
    # Deleter.delete(path)

    # Log the end of the decryption
    # Logger.log({:transmission, :end_decryption}, transmission_uuid)

    # Log the start of the decompression
    # Logger.log({:transmission, :start_decompression}, transmission_uuid)

    # Decompress and delet the decrypted file
    {:ok, paths_of_plain_files} = Decompressor.decompress(decrypted_file_path)
    Deleter.delete(decrypted_file_path)

    # Log the end of the decompression
    # Logger.log({:transmission, :end_decompression}, transmission_uuid)

    # Log the start of the upload
    # Logger.log({:transmission, :start_upload}, transmission_uuid)

    Logger.log(:start_store, transmission_uuid)
    # For each file, upload it to the repository
    results = Enum.map(
      paths_of_plain_files,
      fn plain_file_path ->
        # The current code uses DCM4CHE
        # Let's compare DCMTK and DCM4CHE in order
        # to achieve same functionality
        # DCMTK     |     DCM4CHE    |     Description
        # -d        |     ...        |     Debug Mode
        # -aec      |     ...        |     Theirs Application Entity Title
        # -aet      |     ...        |     Our Application Entity Title
        # ...       |     -c         |     Destination spec
        # ...       |     -b         |     Source spec
        # Example of storescu command on DCM4CHE
        # storescu -c ANY-SCP@137.184.192.219:6000 "files/"
        System.cmd(
          "storescu",
          [
            "-c",
            "#{repository_aetitle}@#{repository_host}:#{repository_port}",
            "-b",
            self_ae_title,
            "#{plain_file_path}"
          ]
        )

        # After tests, I've confirmed that the command above works
        # This deprecated code uses DCMTK
        # System.cmd(
        #   "storescu",
        #   [
        #     "-d",
        #     "-aec",
        #     repository_aetitle,
        #     "-aet",
        #     uploader_uuid,
        #     repository_host,
        #     repository_port,
        #     plain_file_path
        #   ]
        # )
      end
    )

    success =
    Enum.reduce(results, true, fn {_, exit_status}, acc ->
      exit_status == 0 and acc
    end)

    IO.inspect("Results of STORE:")

    if success do
      Logger.log(:end_transmission, transmission_uuid)
      IO.inspect("STORE of Transmission #{transmission_uuid} successful")
      Deleter.delete_all(paths_of_plain_files)
      Deleter.delete(path)
      {:ok, :store}
    else
      Logger.log(:error_transmission, transmission_uuid)
      IO.inspect("STORE of Transmission #{transmission_uuid} failed")
      {:error, :store}
    end
  end

  defp extract_transmission_uuid(path) do
    if !String.contains?(path, ".gitignore") and String.ends_with?(path, ".zip.gpg") do
      String.split(path, "/")
      |> List.last()
      |> String.replace(".zip", "")
      |> String.replace(".gpg", "")
    else
      nil
    end
  end
end

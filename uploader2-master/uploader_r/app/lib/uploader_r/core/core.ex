defmodule UploaderR.Core do
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
    # ...
    {:ok, %{watcher_pid: watcher_pid}}
  end

  def handle_info({:file_event, watcher_pid, {path, events}}, %{watcher_pid: watcher_pid} = state) do
    # Get the transmission_uuid from the path
    transmission_uuid =
      String.split(path, "/")
      |> List.last()
      |> String.replace(".zip", "")
      |> String.replace(".gpg", "")

    IO.inspect({events, path})

    if Enum.member?(events, :moved_to) do
      IO.inspect("Find :moved_to event")

      Task.Supervisor.async_nolink(MyApp.TaskSupervisor, fn -> upload(path, transmission_uuid) end)
    end

    {:noreply, state}
  end

  def handle_info({:file_event, watcher_pid, :stop}, %{watcher_pid: watcher_pid} = state) do
    # Your own logic when monitor stop

    {:noreply, state}
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
    IO.inspect("Started upload process")

    # Get the repository config
    self_config = Config.get_self_config!()

    repository_host = self_config.host
    repository_port = self_config.port
    uploader_uuid = self_config.uuid
    repository_aetitle = self_config.repository_ae_title
    self_ae_title = if byte_size(self_config.self_ae_title) > 0, do: self_config.self_ae_title, else: "UPLOADER_R"

    IO.inspect("REPOSITORY_HOST: #{repository_host}")

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

    IO.inspect("Results of STORE")
    IO.inspect(results)
    IO.inspect(success)

    if success do
      Logger.log(:end_transmission, transmission_uuid)
    else
      Logger.log(:error_transmission, transmission_uuid)
    end

    # Delete the list of files
    Deleter.delete_all(paths_of_plain_files)

    # Log the end of the upload
    # Logger.log({:transmission, :end_upload}, transmission_uuid)
  end
end

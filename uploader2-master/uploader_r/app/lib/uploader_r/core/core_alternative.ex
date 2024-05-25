defmodule UploaderR.CoreAlternative do
  use GenServer

  alias UploaderR.Core.Decompressor

  alias UploaderR.Core.Decrypter

  alias UploaderR.Config

  alias UploaderR.Core.Deleter

  alias UploaderR.Core.Logger

  @trigger_count 3

  @sucess_code 0

  def start_link(args) do
    GenServer.start_link(__MODULE__, args)
  end

  def init(args) do
    # Start the FileSystem process
    {:ok, watcher_pid} = FileSystem.start_link(args)
    # Makes the FileSystem process send messages to this watcher
    FileSystem.subscribe(watcher_pid)
    # ...
    {:ok, %{watcher_pid: watcher_pid, queue_size: 0, is_storing: false}}
  end

  def handle_info({:file_event, watcher_pid, {path, events}}, %{watcher_pid: watcher_pid, queue_size: previous_queue_size, is_storing: is_storing} = state) do
    # Get the transmission_uuid from the path
    transmission_uuid =
      String.split(path, "/")
      |> List.last()
      |> String.replace(".zip", "")
      |> String.replace(".gpg", "")

    IO.inspect("The file system events were:")

    IO.inspect({events, path})

    IO.inspect("-------------------------")

    if Enum.member?(events, :moved_to) do
      IO.inspect("#{previous_queue_size + 1}/#{(@trigger_count)}")
      Task.Supervisor.async_nolink(MyApp.TaskSupervisor, fn -> prepare(path, transmission_uuid) end)
      if previous_queue_size + 1 >= (@trigger_count) and is_storing == false do
        self_config = Config.get_self_config!()

        repository_host = self_config.host
        repository_port = self_config.port
        uploader_uuid = self_config.uuid
        repository_aetitle = self_config.repository_ae_title
        self_ae_title = if byte_size(self_config.self_ae_title) > 0, do: self_config.self_ae_title, else: "UPLOADER_R"

        Task.Supervisor.async_nolink(MyApp.TaskSupervisor, fn ->

          {_, exit_code} = System.cmd(
            "storescu",
            [
              "-c",
              "#{repository_aetitle}@#{repository_host}:#{repository_port}",
              "-b",
              self_ae_title,
              "/app/decompressed/"
            ]
          )


          if exit_code != @sucess_code do
            {:error, :store, exit_code}
          else
            {:ok, :store}
          end

        end)

        {:noreply, %{watcher_pid: watcher_pid, queue_size: 0, is_storing: true}}
      else
        {:noreply, %{watcher_pid: watcher_pid, queue_size: previous_queue_size + 1, is_storing: is_storing}}
      end
    else
      # The state is unchanged.
      {:noreply, state}
    end

    # {:noreply, state}
  end

  def handle_info({:file_event, watcher_pid, :stop}, %{watcher_pid: watcher_pid, queue_size: 0, is_storing: is_storing} = state) do
    # Your own logic when monitor stop

    {:noreply, state}
  end

  def handle_info({pid, :ok}, state) do
  {:noreply, state}
  end

  def handle_info({pid, {text, status_code}}, state) do

    {:noreply, state}
  end

  def handle_info({pid, {:error, :store, code}}, %{watcher_pid: watcher_pid, queue_size: previous_queue_size, is_storing: is_storing} = state) do
    IO.inspect("Error while synchronizing: #{code}")
    if is_storing == false do
      IO.inspect("At the ending of a synchronization, the is_storing flag was false. which is inconsistent state")
    end
    # Set the is_storing flag to false.
    {:noreply, %{watcher_pid: watcher_pid, queue_size: 0, is_storing: false}}
  end

  def handle_info({pid, {:ok, :store}}, %{watcher_pid: watcher_pid, queue_size: previous_queue_size, is_storing: is_storing} = state) do
    IO.inspect("Synchronization completed")
    if is_storing == false do
      IO.inspect("At the ending of a synchronization, the is_storing flag was false. which is inconsistent state")
    end
    # Set the is_storing flag to false.
    {:noreply, %{watcher_pid: watcher_pid, queue_size: 0, is_storing: false}}
  end

  # The task was sucessful
  def handle_info({ref, answer}, %{watcher_pid: watcher_pid, queue_size: 0, is_storing: is_storing} = state) do
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

  defp prepare(path, transmission_uuid) do
    IO.inspect("Started upload process")

    Logger.log(:start_processing, transmission_uuid)
    # Decrypt and delete the encrypted file
    decrypted_file_path = Decrypter.decrypt(path)

    # Decompress and delet the decrypted file
    {:ok, paths_of_plain_files} = Decompressor.decompress(decrypted_file_path)
    Deleter.delete(decrypted_file_path)
  end
end

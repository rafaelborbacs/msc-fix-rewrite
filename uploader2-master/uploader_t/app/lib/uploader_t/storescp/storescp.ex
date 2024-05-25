defmodule UploaderT.StoreSCP do
  use GenServer

  alias UploaderT.Config

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: TxStoreSCP)
  end

  def init(args) do

    {:os_pid, pid} = initialize(:os_scp)

    {
      :ok,
      %{os_pid: pid}
    }
  end



  def handle_call(
        :restart,
        _from,
        %{os_pid: old_pid} = state
      ) do

    terminate(:os_pid, old_pid)

    {:os_pid, new_pid} = initialize(:os_scp)

    {
      :reply,
      :ok,
      %{os_pid: new_pid}
    }
  end

  def restart() do
      GenServer.call(TxStoreSCP, :restart)
  end

  defp initialize(:os_scp) do
    path = System.find_executable("storescp")

    source_config = Config.get_source_config!()

    port = Port.open(
        {:spawn_executable, path},
        [
        {:args, ["+xa", "#{source_config.port}", "-od",  "observable", "-aet", source_config.ae_title]},
        :stream, :binary, :exit_status, :hide, :use_stdio, :stderr_to_stdout
        ]
      )

    {:os_pid, pid} = Port.info(port, :os_pid)

  end

  defp terminate(:os_pid, pid) do
    System.cmd("kill", ["#{pid}"])
  end

end

defmodule UploaderR.StoreSCP do
  use GenServer

  alias UploaderR.Config

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: RxEchoSCP)
  end

  def init(args) do

    {:os_pid, pid} = initialize(:os_scp)

    {
      :ok,
      %{os_pid: pid}
    }
  end

  def handle_info(info, state) do
    IO.inspect("EchoSCPInfo:")
    IO.inspect(info)
    {:noreply, state}
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
      GenServer.call(RxEchoSCP, :restart)
  end

  # exec storescp -b STORESCP:7000 --directory /dev/null &
  defp initialize(:os_scp) do
    path = System.find_executable("storescp")

    source_config = Config.get_self_config!()

    IO.inspect("Config:")
    IO.inspect(source_config)

    port = Port.open(
        {:spawn_executable, path},
        [
        # {:args, ["+xa", "#{source_config.port}", "-od",  "observable", "-aet", source_config.ae_title]},
        {:args, ["-b", "#{source_config.self_ae_title}:7000", "--directory", "/dev/null"]},
        :stream, :binary, :exit_status, :hide, :use_stdio, :stderr_to_stdout
        ]
      )

    Port.info(port, :os_pid)
    |>
    IO.inspect()

  end

  defp terminate(:os_pid, pid) do
    System.cmd("kill", ["#{pid}"])
  end

end

defmodule UploaderR.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  alias UploaderR.SSH

  @impl true
  def start(_type, _args) do
    SSH.generate_keys()

    children = [
      {Task.Supervisor, name: MyApp.TaskSupervisor},
      # Start the Ecto repository
      UploaderR.Repo,
      # Start the Telemetry supervisor
      UploaderRWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: UploaderR.PubSub},
      # Start the Endpoint (http/https)
      UploaderRWeb.Endpoint,
      # Start a worker by calling: UploaderR.Worker.start_link(arg)
      # {UploaderR.Worker, arg}
      {UploaderR.CoreTimedList, dirs: ["/home/uploader_t_1"]},
      {
        UploaderR.MQTT,
        [
          initial_topics: [
            "G/connect/T/+/R/+",
            "G/disconnect/T/+/R/+"
          ],
          host: Application.fetch_env!(:uploader_r, :mqtt_host) |> String.to_charlist,
          port: Application.fetch_env!(:uploader_r, :mqtt_port) |> String.to_integer
        ]
      },
      UploaderR.StoreSCP
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: UploaderR.Supervisor]

    {:ok, pid} = Supervisor.start_link(children, opts)

    notify_uploader_network(:start)

    {:ok, pid}
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    UploaderRWeb.Endpoint.config_change(changed, removed)
    :ok
  end

  defp notify_uploader_network(:start) do
    UploaderR.MQTT.publish(
      "R/#{SSH.identifier(:self)}/start",
      Jason.encode!(%{
        public_key: "#{SSH.public_key()}",
        r_enabled: true
      })
    )
  end
end

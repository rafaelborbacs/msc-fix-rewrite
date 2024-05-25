defmodule UploaderT.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  alias UploaderT.SSH

  @impl true
  def start(_type, _args) do
    SSH.generate_keys()

    IO.inspect("Starting UploaderT")
    IO.inspect(Application.fetch_env!(:uploader_t, :mqtt_host))
    IO.inspect(Application.fetch_env!(:uploader_t, :mqtt_port))

    children = [
      {Task.Supervisor, name: MyApp.TaskSupervisor},
      # Start the Ecto repository
      UploaderT.Repo,
      # Start the Telemetry supervisor
      UploaderTWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: UploaderT.PubSub},
      # Start the Endpoint (http/https)
      UploaderTWeb.Endpoint,
      # Start a worker by calling: UploaderT.Worker.start_link(arg)
      # {UploaderT.Worker, arg}
      {UploaderT.CoreList, dirs: ["observable"]},
      {
        UploaderT.MQTT,
        [
          initial_topics: [
            "G/retry/T/+/transmission/+",
            "G/delete/T/+/transmission/+"
            ],
            host: Application.fetch_env!(:uploader_t, :mqtt_host) |> String.to_charlist,
            port: Application.fetch_env!(:uploader_t, :mqtt_port) |> String.to_integer
          ]
        },
      UploaderT.StoreSCP,
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: UploaderT.Supervisor]

    {:ok, pid} = Supervisor.start_link(children, opts)

    notify_uploader_network(:start)

    UploaderT.StoreSCP.start_link([])

    {:ok, pid}
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    UploaderTWeb.Endpoint.config_change(changed, removed)
    :ok
  end

  defp notify_uploader_network(:start) do
    UploaderT.MQTT.publish(
      "T/#{SSH.identifier(:self)}/start",
      Jason.encode!(%{
        public_key: "#{SSH.public_key()}",
        t_enabled: true
      })
    )
  end

end

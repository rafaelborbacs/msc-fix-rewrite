defmodule UploaderG.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      UploaderG.Repo,
      # Start the Telemetry supervisor
      UploaderGWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: UploaderG.PubSub},
      # Start the Endpoint (http/https)
      UploaderGWeb.Endpoint,
      # Start a worker by calling: UploaderG.Worker.start_link(arg)
      # {UploaderG.Worker, arg}
      {
        UploaderG.MQTT,
        [
          initial_topics: [
            # System logs
            "logs",
            # Transmissions
            "transmission",
            # Receiver Unit Start
            "R/+/start",
            # Receiver Config Update
            "R/+/config",
            # Transmitter Unit Start
            "T/+/start",
            # Transmitter Config Update
            "T/+/config/source",
            # Receiver Config Update
            "T/+/config/destination",
            # Response for the request of a Connection between Transmitter and Receiver
            "+/connection_response",
            # Request for a Connection between Transmitter and Receiver
            "+/connection_request",
            # Logs of a certain Transmission coming from a certain Receiver
            "R/+/transmission/+/logs",
            # Logs of a certain Transmission coming from a certain Receiver
            "T/+/transmission/+/logs",
            # Logs of a certain Transmissor
            "T/+/logs",
            # Logs of a certain Receiver
            "R/+/logs"
          ],
          host: Application.fetch_env!(:uploader_g, :mqtt_host) |> String.to_charlist(),
          port: Application.fetch_env!(:uploader_g, :mqtt_port) |> String.to_integer()
        ]
      }
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: UploaderG.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    UploaderGWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end

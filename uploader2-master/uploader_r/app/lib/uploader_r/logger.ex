defmodule UploaderR.Logger do
  alias UploaderR.MQTT
  alias UploaderR.SSH

  def log(:initialization) do
    Task.start(fn ->
      MQTT.publish(
        "logs",
        Jason.encode!(%{
          event: "Inicialização",
          logged_at: DateTime.now!("America/Fortaleza", Tz.TimeZoneDatabase),
          message: "O UploaderR se inicializou",
          uuid: Ecto.UUID.bingenerate() |> Base.encode16(),
          origin: SSH.identifier(:self)
          # uuid: :crypto.hash(:md5, SSH.public_key) |> IO.inspect
        })
      )
    end)
  end
end

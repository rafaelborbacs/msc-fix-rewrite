defmodule UploaderT.Logger do
  alias UploaderT.MQTT
  alias UploaderT.KeyManager

  def log(:initialization) do
    Task.start(fn -> MQTT.publish("logs", Jason.encode!(%{
      event: "Inicialização",
      logged_at: DateTime.now!("America/Fortaleza", Tz.TimeZoneDatabase),
      message: "O UploaderT se inicializou",
      uuid: KeyManager.uuid,
     # uuid: :crypto.hash(:md5, KeyManager.public_key) |> IO.inspect
    })) end)
  end

end

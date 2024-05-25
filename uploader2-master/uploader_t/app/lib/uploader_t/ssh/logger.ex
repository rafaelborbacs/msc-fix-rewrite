defmodule UploaderT.SSH.Logger do
  @moduledoc """
  This module provides a MQTT logger for the key manager.
  """
  alias UploaderT.MQTT
  alias UploaderT.SSH
  alias Ecto.UUID

  @doc """
  Publishes a message to the MQTT logging topic.

  The supported message types are:

  :public_key_publication
  """
  def log(type)

  def log(:public_key_publication) do
    MQTT.publish(
      "logs",
      Jason.encode!(%{
        event: "Publicação de Chave Pública",
        logged_at: DateTime.now!("Etc/UTC"),
        message: "Uploader T enviou solicitação de conexão",
        uuid: UUID.generate(),
        origin: SSH.public_key
      })
    )
  end
end

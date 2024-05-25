defmodule UploaderR.SSH.Logger do
  @moduledoc """
  This module provides a MQTT logger for the key manager.
  """
  alias UploaderR.MQTT
  alias UploaderR.SSH

  @doc """
  Publishes a message to the MQTT logging topic.

  The supported message types are:

  :public_key_receivement
  """
  def log(type)

  def log(:public_key_receivement) do
    MQTT.publish(
      "logs",
      Jason.encode!(%{
        event: "Recebimento da Chave Pública do Uploader T",
        logged_at: DateTime.now!("Etc/UTC"),
        message: "Chave pública recebida pelo broker",
        uuid: SSH.identifier(:self)
      })
    )
  end
end

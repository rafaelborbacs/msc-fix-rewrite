defmodule UploaderT.Core.Logger do
  @moduledoc """
  This module provides a simple logging interface for the Core module.
  """

  alias UploaderT.MQTT
  alias UploaderT.SSH
  alias UploaderT.Config

  @doc """
  Sends a log message to the MQTT broker.

  Supported log types on this module are: \n
  :start_encryption \n
  :end_encryption \n
  :error_encryption \n
  :start_compression \n
  :end_compression \n
  :error_compression \n
  :start_transmission \n
  :end_transmission \n
  :error_transmission \n
  """
  def log(type, payload)

  def log({:transmission, :start_encryption}, transmission_uuid) do
    MQTT.publish(
      "T/#{SSH.identifier(:self)}/transmission/#{transmission_uuid}/logs",
      Jason.encode!(%{
        event: "Início de Cifragem",
        logged_at: DateTime.now!("Etc/UTC"),
        message: "Início de Cifragem de arquivos"
      })
    )
  end

  def log({:transmission, :end_encryption}, transmission_uuid) do
    MQTT.publish(
      "T/#{SSH.identifier(:self)}/transmission/#{transmission_uuid}/logs",
      Jason.encode!(%{
        event: "Fim de Cifragem",
        logged_at: DateTime.now!("Etc/UTC"),
        message: "Fim de Cifragem de arquivos"
      })
    )
  end

  def log({:transmission, :error_encryption}, transmission_uuid) do
    MQTT.publish(
      "T/#{SSH.identifier(:self)}/transmission/#{transmission_uuid}/logs",
      Jason.encode!(%{
        event: "Erro de Cifragem",
        logged_at: DateTime.now!("Etc/UTC"),
        message: "Erro de Cifragem de arquivos"
      })
    )
  end

  def log({:transmission, :start_compression}, transmission_uuid) do
    MQTT.publish(
      "T/#{SSH.identifier(:self)}/transmission/#{transmission_uuid}/logs",
      Jason.encode!(%{
        event: "Início de Compressão",
        logged_at: DateTime.now!("Etc/UTC"),
        message: "Início de compressão de arquivos"
      })
    )
  end

  def log({:transmission, :end_compression}, transmission_uuid) do
    MQTT.publish(
      "T/#{SSH.identifier(:self)}/transmission/#{transmission_uuid}/logs",
      Jason.encode!(%{
        event: "Fim de Compressão",
        logged_at: DateTime.now!("Etc/UTC"),
        message: "Fim de compressão de arquivos"
      })
    )
  end

  def log({:transmission, :error_compression}, transmission_uuid) do
    MQTT.publish(
      "T/#{SSH.identifier(:self)}/transmission/#{transmission_uuid}/logs",
      Jason.encode!(%{
        event: "Erro de Compressão",
        logged_at: DateTime.now!("Etc/UTC"),
        message: "Erro de compressão de arquivos"
      })
    )
  end



  def log({:transmission, :end_sync}, transmission_uuid) do
    # Success Logs are not meaningful when they are numerous and redundant
    MQTT.publish(
      "T/#{SSH.identifier(:self)}/transmission/#{transmission_uuid}/logs",
      Jason.encode!(%{
        event: "Fim de Sincronização",
        logged_at: DateTime.now!("Etc/UTC"),
        message: transmission_uuid
      })
    )
  end

  def log({:transmission, :error_sync}, transmission_uuid) do
    # MQTT.publish(
    #   "T/#{SSH.identifier(:self)}/transmission/#{transmission_uuid}/logs",
    #   Jason.encode!(%{
    #     event: "Erro de Sincronização",
    #     logged_at: DateTime.now!("Etc/UTC"),
    #     message: transmission_uuid
    #   })
    # )
  end

  def log({:transmission, :forbidden}) do
    MQTT.publish(
      "T/#{SSH.identifier(:self)}/logs",
      Jason.encode!(%{
        event: "Acesso Negado",
        logged_at: DateTime.now!("Etc/UTC"),
        message: "Uma transmissão foi negada porque o SCU não está na Allowlist"
      })
    )
  end

  def log(
    :start_transmission,
    %{
      uuid: uuid,
      size: size,
      checksum: checksum,
      study_instance_uid: study_instance_uid,
      study_description: study_description
    }
    ) do
    MQTT.publish(
      "transmission",
      Jason.encode!(%{
        uuid: uuid,
        status: "T - PROCESSING",
        size: size,
        origin: SSH.identifier(:self),
        destination: Config.get_destination_config!().uuid,
        start: DateTime.now!("Etc/UTC"),
        checksum: checksum,
        study_instance_uid: study_instance_uid,
        study_description: study_description
      })
    )
  end

  def log(:end_transmission, %{uuid: uuid}) do
    MQTT.publish(
      "transmission",
      Jason.encode!(%{
        uuid: uuid,
        status: "T - OK",
        end: DateTime.now!("Etc/UTC")
      })
    )
  end

  def log(:error_transmission, %{uuid: uuid}) do
    MQTT.publish(
      "transmission",
      Jason.encode!(%{
        uuid: uuid,
        status: "T - ERROR",
        end: DateTime.now!("Etc/UTC")
      })
    )
  end

  def log({:transmission, :start_sync}, transmission_uuid) do
    MQTT.publish(
      "transmission",
      Jason.encode!(%{
        uuid: transmission_uuid,
        status: "T - SYNC",
        end: DateTime.now!("Etc/UTC")
      })
    )
  end
end

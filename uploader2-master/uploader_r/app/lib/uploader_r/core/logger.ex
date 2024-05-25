defmodule UploaderR.Core.Logger do
  @moduledoc """
  This module provides a simple logging interface for the Core module.
  """

  alias UploaderR.MQTT
  alias UploaderR.SSH

  @doc """
  Sends a log message to the MQTT broker.

  Supported log types on this module are: \n
  :start_decryption \n
  :end_decryption \n
  :error_decryption \n
  :start_decompression \n
  :end_decompression \n
  :error_decompression \n
  :start_upload \n
  :end_upload \n
  :error_upload
  """
  def log(type, transmission_uuid)

  def log({:transmission, :start_decryption}, transmission_uuid) do
    MQTT.publish(
      "R/#{SSH.identifier(:self)}/transmission/#{transmission_uuid}/logs",
      Jason.encode!(%{
        event: "Início de Decifragem",
        logged_at: DateTime.now!("Etc/UTC"),
        message: "Início de decifragem de arquivos"
      })
    )
  end

  def log({:transmission, :end_decryption}, transmission_uuid) do
    MQTT.publish(
      "R/#{SSH.identifier(:self)}/transmission/#{transmission_uuid}/logs",
      Jason.encode!(%{
        event: "Fim de Decifragem",
        logged_at: DateTime.now!("Etc/UTC"),
        message: "Fim de decifragem de arquivos"
      })
    )
  end

  def log({:transmission, :error_decryption}, transmission_uuid) do
    MQTT.publish(
      "R/#{SSH.identifier(:self)}/transmission/#{transmission_uuid}/logs",
      Jason.encode!(%{
        event: "Erro de Decifragem",
        logged_at: DateTime.now!("Etc/UTC"),
        message: "Erro de decifragem de arquivos"
      })
    )
  end

  def log({:transmission, :start_decompression}, transmission_uuid) do
    MQTT.publish(
      "R/#{SSH.identifier(:self)}/transmission/#{transmission_uuid}/logs",
      Jason.encode!(%{
        event: "Início de Descompressão",
        logged_at: DateTime.now!("Etc/UTC"),
        message: "Início de descompressão de arquivos"
      })
    )
  end

  def log({:transmission, :end_decompression}, transmission_uuid) do
    MQTT.publish(
      "R/#{SSH.identifier(:self)}/transmission/#{transmission_uuid}/logs",
      Jason.encode!(%{
        event: "Fim de Descompressão",
        logged_at: DateTime.now!("Etc/UTC"),
        message: "Fim de descompressão de arquivos"
      })
    )
  end

  def log({:transmission, :error_decompression}, transmission_uuid) do
    MQTT.publish(
      "R/#{SSH.identifier(:self)}/transmission/#{transmission_uuid}/logs",
      Jason.encode!(%{
        event: "Erro de Descompressão",
        logged_at: DateTime.now!("Etc/UTC"),
        message: "Erro de descompressão de arquivos"
      })
    )
  end

  def log({:transmission, :start_upload}, transmission_uuid) do
    MQTT.publish(
      "R/#{SSH.identifier(:self)}/transmission/#{transmission_uuid}/logs",
      Jason.encode!(%{
        event: "Início de Upload",
        logged_at: DateTime.now!("Etc/UTC"),
        message: "Início de upload de arquivos"
      })
    )
  end

  def log({:transmission, :end_upload}, transmission_uuid) do
    MQTT.publish(
      "R/#{SSH.identifier(:self)}/transmission/#{transmission_uuid}/logs",
      Jason.encode!(%{
        event: "Fim de Upload",
        logged_at: DateTime.now!("Etc/UTC"),
        message: "Fim de upload de arquivos"
      })
    )
  end

  def log({:transmission, :error_upload}, transmission_uuid) do
    MQTT.publish(
      "R/#{SSH.identifier(:self)}/transmission/#{transmission_uuid}/logs",
      Jason.encode!(%{
        event: "Erro de Upload",
        logged_at: DateTime.now!("Etc/UTC"),
        message: "Erro de upload de arquivos"
      })
    )
  end

  def log({:transmission, :start_decrypt}, transmission_uuid) do
    MQTT.publish(
      "R/#{SSH.identifier(:self)}/transmission/#{transmission_uuid}/logs",
      Jason.encode!(%{
        event: "Início da Decifragem",
        logged_at: DateTime.now!("Etc/UTC"),
        message: "Início da Decifragem dos arquivos"
      })
    )
  end

  def log({:transmission, :end_decrypt}, transmission_uuid) do
    MQTT.publish(
      "R/#{SSH.identifier(:self)}/transmission/#{transmission_uuid}/logs",
      Jason.encode!(%{
        event: "Fim da Decifragem",
        logged_at: DateTime.now!("Etc/UTC"),
        message: "Fim da Decifragem dos arquivos"
      })
    )
  end

  def log({:transmission, :error_decrypt}, transmission_uuid) do
    MQTT.publish(
      "R/#{SSH.identifier(:self)}/transmission/#{transmission_uuid}/logs",
      Jason.encode!(%{
        event: "Erro da Decifragem",
        logged_at: DateTime.now!("Etc/UTC"),
        message: "Erro da Decifragem dos arquivos"
      })
    )
  end

  def log(:start_processing, transmission_uuid) do
    MQTT.publish(
      "transmission",
      Jason.encode!(%{
        uuid: transmission_uuid,
        status: "R - PROCESSING",
      })
    )
  end

  def log(:start_store, transmission_uuid) do
    MQTT.publish(
      "transmission",
      Jason.encode!(%{
        uuid: transmission_uuid,
        status: "R - STORE",
      })
    )
  end

  def log(:end_transmission, transmission_uuid) do
    MQTT.publish(
      "transmission",
      Jason.encode!(%{
        uuid: transmission_uuid,
        status: "R - OK",
        end: DateTime.now!("Etc/UTC")
      })
    )
  end

  def log(:error_transmission, transmission_uuid) do
    MQTT.publish(
      "transmission",
      Jason.encode!(%{
        uuid: transmission_uuid,
        status: "R - ERROR",
        end: DateTime.now!("Etc/UTC")
      })
    )
  end
end

defmodule UploaderT.Config do
  @moduledoc """
  The Config context.
  """
  alias UploaderT.Config.SourceConfig
  alias UploaderT.Config.DestinationConfig
  alias UploaderT.SSH

  @doc """
  Gets the current configuration for the Source.

  ## Examples

      iex> get_source_config!
      %SourceConfig{}

  """
  def get_source_config! do
    json =
      with {:ok, body} <- File.read("uploader_t.config.json"),
           {:ok, json} <- Jason.decode(body),
           do: json

    %SourceConfig{
      ae_title: Map.get(json, "ae_title", "DEFAULT_AE_TITLE"),
      ip: Map.get(json, "ip", ""),
      port: Map.get(json, "port", ""),
      location: Map.get(json, "location", ""),
      limit: Map.get(json, "limit", ""),
      sync_timeout: Map.get(json, "sync_timeout", ""),
      processing_timeout: Map.get(json, "processing_timeout", "")
    }
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking source configuration changes.

  ## Examples

      iex> change_source_config(source_config)
      %Ecto.Changeset{data: %SourceConfig{}}

  """
  def change_source_config(source_config, attrs \\ %{}) do
    SourceConfig.changeset(source_config, attrs)
  end

  @doc """
  Updates the source configuration.

  ## Examples

      iex> update_source_config(source_config, %{field: new_value})
      {:ok, %Ecto.Changeset{}}

      iex> update_source_config(source_config, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_source_config(%SourceConfig{} = source_config, attrs) do
    changeset = SourceConfig.changeset(source_config, attrs)

    if changeset.valid? do
      with {:ok, json} <- Jason.encode(attrs), do: File.write("uploader_t.config.json", json)
      {:ok, changeset}
    else
      {:error, changeset}
    end
  end

  @doc """
  Publishes the source configuration to the MQTT broker
  """
  def publish_source_config() do
    source_config = get_source_config!()

    UploaderT.MQTT.publish(
      "T/#{SSH.identifier(:self)}/config/source",
      Jason.encode!(%{
        public_key: SSH.public_key(),
        port: source_config.port,
        host: source_config.ip,
        location: source_config.location,
        limit: source_config.limit,
        sync_timeout: source_config.sync_timeout,
        processing_timeout: source_config.processing_timeout
      })
    )

  end

  #######################################################################################################
  @doc """
  Gets the current configuration for the Destination.

  ## Examples

      iex> get_destination_config!
      %DestinationConfig{}

  """
  def get_destination_config! do
    json =
      with {:ok, body} <- File.read("uploader_r.config.json"),
           {:ok, json} <- Jason.decode(body),
           do: json

    %DestinationConfig{
      ip: Map.get(json, "ip", ""),
      port: Map.get(json, "port", ""),
      uuid: Map.get(json, "uuid", "")
    }
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking destination configuration changes.

  ## Examples

      iex> change_destination_config(destination_config)
      %Ecto.Changeset{data: %DestinationConfig{}}

  """
  def change_destination_config(destination_config, attrs \\ %{}) do
    DestinationConfig.changeset(destination_config, attrs)
  end

  @doc """
  Updates the destination configuration.

  ## Examples

      iex> update_destination_config(destination_config, %{field: new_value})
      {:ok, %Ecto.Changeset{}}

      iex> update_destination_config(destination_config, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_destination_config(%DestinationConfig{} = destination_config, attrs) do
    changeset = DestinationConfig.changeset(destination_config, attrs)

    if changeset.valid? do
      with {:ok, json} <- Jason.encode(attrs), do: File.write("uploader_r.config.json", json)

      {:ok, changeset}
    else
      {:error, changeset}
    end
  end

    @doc """
  Publishes the destination configuration to the MQTT broker
  """
  def publish_destination_config() do
    destination_config = get_destination_config!()

    UploaderT.MQTT.publish(
      "T/#{SSH.identifier(:self)}/config/destination",
      Jason.encode!(%{
        target_public_key_identifier: destination_config.uuid,
        port: destination_config.port,
        host: destination_config.ip,
      })
    )

  end

end

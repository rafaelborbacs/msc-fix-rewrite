defmodule UploaderR.Config do
  @moduledoc """
  The Config context.
  """
  alias UploaderR.Config.SelfConfig

  alias UploaderR.SSH

  @doc """
  Gets the current configuration for the Source.

  ## Examples

      iex> get_source_config!
      %SourceConfig{}

  """
  def get_self_config! do
    json =
      with {:ok, body} <- File.read("self.config.json"),
           {:ok, json} <- Jason.decode(body),
           do: json

    %SelfConfig{
      manager_host: Map.get(json, "manager_host", ""),
      manager_port: Map.get(json, "manager_port", ""),
      repository_ae_title: Map.get(json, "repository_ae_title", ""),
      self_ae_title: Map.get(json, "self_ae_title", ""),
      host: Map.get(json, "host", ""),
      port: Map.get(json, "port", ""),
      uuid: SSH.identifier(:self),
      location: Map.get(json, "location", ""),
      store_timeout: Map.get(json, "store_timeout", ""),
      processing_timeout: Map.get(json, "processing_timeout", "")
    }
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking source configuration changes.

  ## Examples

      iex> change_source_config(source_config)
      %Ecto.Changeset{data: %SourceConfig{}}

  """
  def change_self_config(self_config, attrs \\ %{}) do
    SelfConfig.changeset(self_config, attrs)
  end

  @doc """
  Updates the source configuration.

  ## Examples

      iex> update_source_config(source_config, %{field: new_value})
      {:ok, %Ecto.Changeset{}}

      iex> update_source_config(source_config, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_self_config(%SelfConfig{} = self_config, attrs) do
    changeset = SelfConfig.changeset(self_config, attrs)

    if changeset.valid? do
      with {:ok, json} <- Jason.encode(attrs), do: File.write("self.config.json", json)

      {:ok, changeset}
    else
      {:error, changeset}
    end
  end

  def publish_config() do
    config = get_self_config!()

    UploaderR.MQTT.publish(
      "R/#{SSH.identifier(:self)}/config",
      Jason.encode!(%{
        public_key: SSH.public_key(),
        port: config.port,
        host: config.host,
        location: config.location,
        store_timeout: config.store_timeout,
        processing_timeout: config.processing_timeout
      })
      |> IO.inspect
    )
  end
end

defmodule UploaderRWeb.ConfigController do
  use UploaderRWeb, :controller

  # Let we refer to the module UploaderT.FileStore as FileStore
  alias UploaderR.FileStore

  # ???
  action_fallback UploaderRWeb.FallbackController

  # The config files we deal with in this module
  @filename "self.config.json"

  # Get the config file and return it as JSON
  def get(conn, _params) do
    # Get the file content
    json = FileStore.get(@filename)

    IO.inspect("<>")
    IO.inspect(json)
    # Return the file content as JSON
    render(conn, "index.json", json: json)
  end

  def set(conn, %{"config_data" => config_data}) do
    # Set the file content, store it and return the file content as JSON
    json = FileStore.set(@filename, config_data)
    render(conn, "index.json", json: json)
  end
end

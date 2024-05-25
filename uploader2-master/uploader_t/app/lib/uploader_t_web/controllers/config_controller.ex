defmodule UploaderTWeb.ConfigController do
  use UploaderTWeb, :controller

  # Let we refer to the module UploaderT.FileStore as FileStore
  alias UploaderT.FileStore

  # ???
  action_fallback UploaderTWeb.FallbackController

  # The config files we deal with in this module
  @files %{t: "uploader_t.config.json", r: "uploader_r.config.json"}

  # Get the config file and return it as JSON
  def get(conn, %{"file" => file}) do
    # Get the file name
    filename = get_file_name(file)
    # Get the file content
    json = FileStore.get(filename)
    # Return the file content as JSON
    render(conn, "index.json", json: json)
  end

  def set(conn, %{"file" => file, "config_data" => config_data}) do
    # Get the file name
    filename = get_file_name(file)
    # Set the file content, store it and return the file content as JSON
    json = FileStore.set(filename, config_data)
    render(conn, "index.json", json: json)
  end

  # From a key like "t" or "r" return the filename
  defp get_file_name(file) do
    Map.get(@files, String.to_existing_atom(file))
  end
end

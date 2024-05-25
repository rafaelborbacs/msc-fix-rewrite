defmodule UploaderTWeb.UploaderRController do
  use UploaderTWeb, :controller

  alias UploaderT.FileStore

  action_fallback UploaderTWeb.FallbackController

  @filename "uploader_r.config.json"

  def get(conn, _params) do
    uploader_r = FileStore.get(@filename)
    render(conn, "index.json", uploader_r: uploader_r)
  end
  def set(conn, uploader_r_params) do
    uploader_r = FileStore.set(@filename, uploader_r_params)
    render(conn, "index.json", uploader_r: uploader_r)
  end
end

defmodule UploaderTWeb.UIController do
  use UploaderTWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end

  def uploader_r(conn, _params) do
    render(conn, "uploader_r.html")
  end

  def uploader_t(conn, _params) do
    render(conn, "uploader_t.html")
  end

  def modalidades(conn, _params) do
    render(conn, "modalidades.html")
  end
end

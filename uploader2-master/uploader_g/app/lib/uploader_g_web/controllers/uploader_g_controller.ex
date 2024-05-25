defmodule UploaderGWeb.UploaderGController do
  use UploaderGWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end

  def dashboard(conn, _params) do
    render(conn, "dashboard.html")
  end

  def unidades(conn, _params) do
    render(conn, "unidades.html")
  end

  def transmissoes(conn, _params) do
    render(conn, "transmissoes.html")
  end

  def logs(conn, _params) do
    render(conn, "logs.html")
  end
end

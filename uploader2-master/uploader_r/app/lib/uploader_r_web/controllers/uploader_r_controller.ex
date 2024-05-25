defmodule UploaderRWeb.UploaderRController do
  use UploaderRWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end

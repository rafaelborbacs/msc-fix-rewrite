defmodule UploaderTWeb.UploaderRView do
  use UploaderTWeb, :view
  alias UploaderTWeb.UploaderRView

  def render("index.json", %{uploader_r: uploader_r}) do
    uploader_r
  end
end

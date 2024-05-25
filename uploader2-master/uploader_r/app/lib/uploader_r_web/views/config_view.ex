defmodule UploaderRWeb.ConfigView do
  use UploaderRWeb, :view
  alias UploaderRWeb.ConfigView

  def render("index.json", %{json: json}) do
    IO.inspect(json)
    json
  end
end

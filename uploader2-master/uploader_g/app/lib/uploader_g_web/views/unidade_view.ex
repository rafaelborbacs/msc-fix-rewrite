defmodule UploaderGWeb.UnidadeView do
  use UploaderGWeb, :view
  alias UploaderGWeb.UnidadeView

  def render("index.json", %{unidades: unidades}) do
    %{data: render_many(unidades, UnidadeView, "unidade.json")}
  end

  def render("show.json", %{unidade: unidade}) do
    %{data: render_one(unidade, UnidadeView, "unidade.json")}
  end

  def render("unidade.json", %{unidade: unidade}) do
    %{
      id: unidade.id,
      localizacao: unidade.localizacao,
      ip: unidade.ip,
      porta: unidade.porta,
      chave_publica: unidade.chave_publica
    }
  end
end

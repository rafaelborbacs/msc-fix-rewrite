defmodule UploaderTWeb.ModalidadeView do
  use UploaderTWeb, :view
  alias UploaderTWeb.ModalidadeView

  def render("index.json", %{modalidades: modalidades}) do
    %{data: render_many(modalidades, ModalidadeView, "modalidade.json")}
  end

  def render("show.json", %{modalidade: modalidade}) do
    %{data: render_one(modalidade, ModalidadeView, "modalidade.json")}
  end

  def render("modalidade.json", %{modalidade: modalidade}) do
    %{
      id: modalidade.id,
      nome: modalidade.nome,
      localizacao: modalidade.localizacao,
      ip: modalidade.ip,
      porta: modalidade.porta
    }
  end
end

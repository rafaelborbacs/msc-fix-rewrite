defmodule UploaderTWeb.ModalidadeController do
  use UploaderTWeb, :controller

  alias UploaderT.Modalidades
  alias UploaderT.Modalidades.Modalidade

  action_fallback UploaderTWeb.FallbackController

  def index(conn, _params) do
    modalidades = Modalidades.list_modalidades()
    render(conn, "index.json", modalidades: modalidades)
  end

  def create(conn, modalidade_params) do
    with {:ok, %Modalidade{} = modalidade} <- Modalidades.create_modalidade(modalidade_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.modalidade_path(conn, :show, modalidade))
      |> render("show.json", modalidade: modalidade)
    end
  end

  def show(conn, %{"id" => id}) do
    modalidade = Modalidades.get_modalidade!(id)
    render(conn, "show.json", modalidade: modalidade)
  end

  def update(conn, %{"id" => id, "modalidade" => modalidade_params}) do
    modalidade = Modalidades.get_modalidade!(id)

    with {:ok, %Modalidade{} = modalidade} <- Modalidades.update_modalidade(modalidade, modalidade_params) do
      render(conn, "show.json", modalidade: modalidade)
    end
  end

  def delete(conn, %{"id" => id}) do
    modalidade = Modalidades.get_modalidade!(id)

    with {:ok, %Modalidade{}} <- Modalidades.delete_modalidade(modalidade) do
      send_resp(conn, :no_content, "")
    end
  end
end

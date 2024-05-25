defmodule UploaderGWeb.UnidadeController do
  use UploaderGWeb, :controller

  alias UploaderG.Unidades
  alias UploaderG.Unidades.Unidade

  action_fallback UploaderGWeb.FallbackController

  def index(conn, _params) do
    unidades = Unidades.list_unidades()
    render(conn, "index.json", unidades: unidades)
  end

  def create(conn, %{"unidade" => unidade_params}) do
    with {:ok, %Unidade{} = unidade} <- Unidades.create_unidade(unidade_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.unidade_path(conn, :show, unidade))
      |> render("show.json", unidade: unidade)
    end
  end

  def show(conn, %{"id" => id}) do
    unidade = Unidades.get_unidade!(id)
    render(conn, "show.json", unidade: unidade)
  end

  def update(conn, %{"id" => id, "unidade" => unidade_params}) do
    unidade = Unidades.get_unidade!(id)

    with {:ok, %Unidade{} = unidade} <- Unidades.update_unidade(unidade, unidade_params) do
      render(conn, "show.json", unidade: unidade)
    end
  end

  def delete(conn, %{"id" => id}) do
    unidade = Unidades.get_unidade!(id)

    with {:ok, %Unidade{}} <- Unidades.delete_unidade(unidade) do
      send_resp(conn, :no_content, "")
    end
  end
end

defmodule UploaderTWeb.ModalidadeControllerTest do
  use UploaderTWeb.ConnCase

  import UploaderT.ModalidadesFixtures

  alias UploaderT.Modalidades.Modalidade

  @create_attrs %{
    ip: "some ip",
    localizacao: "some localizacao",
    nome: "some nome",
    porta: 42
  }
  @update_attrs %{
    ip: "some updated ip",
    localizacao: "some updated localizacao",
    nome: "some updated nome",
    porta: 43
  }
  @invalid_attrs %{ip: nil, localizacao: nil, nome: nil, porta: nil}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all modalidades", %{conn: conn} do
      conn = get(conn, Routes.modalidade_path(conn, :index))
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create modalidade" do
    test "renders modalidade when data is valid", %{conn: conn} do
      conn = post(conn, Routes.modalidade_path(conn, :create), modalidade: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.modalidade_path(conn, :show, id))

      assert %{
               "id" => ^id,
               "ip" => "some ip",
               "localizacao" => "some localizacao",
               "nome" => "some nome",
               "porta" => 42
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.modalidade_path(conn, :create), modalidade: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update modalidade" do
    setup [:create_modalidade]

    test "renders modalidade when data is valid", %{
      conn: conn,
      modalidade: %Modalidade{id: id} = modalidade
    } do
      conn =
        put(conn, Routes.modalidade_path(conn, :update, modalidade), modalidade: @update_attrs)

      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.modalidade_path(conn, :show, id))

      assert %{
               "id" => ^id,
               "ip" => "some updated ip",
               "localizacao" => "some updated localizacao",
               "nome" => "some updated nome",
               "porta" => 43
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, modalidade: modalidade} do
      conn =
        put(conn, Routes.modalidade_path(conn, :update, modalidade), modalidade: @invalid_attrs)

      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete modalidade" do
    setup [:create_modalidade]

    test "deletes chosen modalidade", %{conn: conn, modalidade: modalidade} do
      conn = delete(conn, Routes.modalidade_path(conn, :delete, modalidade))
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, Routes.modalidade_path(conn, :show, modalidade))
      end
    end
  end

  defp create_modalidade(_) do
    modalidade = modalidade_fixture()
    %{modalidade: modalidade}
  end
end

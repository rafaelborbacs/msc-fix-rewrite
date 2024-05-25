defmodule UploaderGWeb.UnidadeControllerTest do
  use UploaderGWeb.ConnCase

  import UploaderG.UnidadesFixtures

  alias UploaderG.Unidades.Unidade

  @create_attrs %{
    chave_publica: "some chave_publica",
    ip: "some ip",
    localizacao: "some localizacao",
    porta: 42
  }
  @update_attrs %{
    chave_publica: "some updated chave_publica",
    ip: "some updated ip",
    localizacao: "some updated localizacao",
    porta: 43
  }
  @invalid_attrs %{chave_publica: nil, ip: nil, localizacao: nil, porta: nil}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all unidades", %{conn: conn} do
      conn = get(conn, Routes.unidade_path(conn, :index))
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create unidade" do
    test "renders unidade when data is valid", %{conn: conn} do
      conn = post(conn, Routes.unidade_path(conn, :create), unidade: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.unidade_path(conn, :show, id))

      assert %{
               "id" => ^id,
               "chave_publica" => "some chave_publica",
               "ip" => "some ip",
               "localizacao" => "some localizacao",
               "porta" => 42
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.unidade_path(conn, :create), unidade: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update unidade" do
    setup [:create_unidade]

    test "renders unidade when data is valid", %{conn: conn, unidade: %Unidade{id: id} = unidade} do
      conn = put(conn, Routes.unidade_path(conn, :update, unidade), unidade: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.unidade_path(conn, :show, id))

      assert %{
               "id" => ^id,
               "chave_publica" => "some updated chave_publica",
               "ip" => "some updated ip",
               "localizacao" => "some updated localizacao",
               "porta" => 43
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, unidade: unidade} do
      conn = put(conn, Routes.unidade_path(conn, :update, unidade), unidade: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete unidade" do
    setup [:create_unidade]

    test "deletes chosen unidade", %{conn: conn, unidade: unidade} do
      conn = delete(conn, Routes.unidade_path(conn, :delete, unidade))
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, Routes.unidade_path(conn, :show, unidade))
      end
    end
  end

  defp create_unidade(_) do
    unidade = unidade_fixture()
    %{unidade: unidade}
  end
end

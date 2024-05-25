defmodule UploaderG.UnidadesTest do
  use UploaderG.DataCase

  alias UploaderG.Unidades

  describe "unidades" do
    alias UploaderG.Unidades.Unidade

    import UploaderG.UnidadesFixtures

    @invalid_attrs %{chave_publica: nil, ip: nil, localizacao: nil, porta: nil}

    test "list_unidades/0 returns all unidades" do
      unidade = unidade_fixture()
      assert Unidades.list_unidades() == [unidade]
    end

    test "get_unidade!/1 returns the unidade with given id" do
      unidade = unidade_fixture()
      assert Unidades.get_unidade!(unidade.id) == unidade
    end

    test "create_unidade/1 with valid data creates a unidade" do
      valid_attrs = %{
        chave_publica: "some chave_publica",
        ip: "some ip",
        localizacao: "some localizacao",
        porta: 42
      }

      assert {:ok, %Unidade{} = unidade} = Unidades.create_unidade(valid_attrs)
      assert unidade.chave_publica == "some chave_publica"
      assert unidade.ip == "some ip"
      assert unidade.localizacao == "some localizacao"
      assert unidade.porta == 42
    end

    test "create_unidade/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Unidades.create_unidade(@invalid_attrs)
    end

    test "update_unidade/2 with valid data updates the unidade" do
      unidade = unidade_fixture()

      update_attrs = %{
        chave_publica: "some updated chave_publica",
        ip: "some updated ip",
        localizacao: "some updated localizacao",
        porta: 43
      }

      assert {:ok, %Unidade{} = unidade} = Unidades.update_unidade(unidade, update_attrs)
      assert unidade.chave_publica == "some updated chave_publica"
      assert unidade.ip == "some updated ip"
      assert unidade.localizacao == "some updated localizacao"
      assert unidade.porta == 43
    end

    test "update_unidade/2 with invalid data returns error changeset" do
      unidade = unidade_fixture()
      assert {:error, %Ecto.Changeset{}} = Unidades.update_unidade(unidade, @invalid_attrs)
      assert unidade == Unidades.get_unidade!(unidade.id)
    end

    test "delete_unidade/1 deletes the unidade" do
      unidade = unidade_fixture()
      assert {:ok, %Unidade{}} = Unidades.delete_unidade(unidade)
      assert_raise Ecto.NoResultsError, fn -> Unidades.get_unidade!(unidade.id) end
    end

    test "change_unidade/1 returns a unidade changeset" do
      unidade = unidade_fixture()
      assert %Ecto.Changeset{} = Unidades.change_unidade(unidade)
    end
  end
end

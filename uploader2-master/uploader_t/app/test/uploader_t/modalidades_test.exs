defmodule UploaderT.ModalidadesTest do
  use UploaderT.DataCase

  alias UploaderT.Modalidades

  describe "modalidades" do
    alias UploaderT.Modalidades.Modalidade

    import UploaderT.ModalidadesFixtures

    @invalid_attrs %{ip: nil, localizacao: nil, nome: nil, porta: nil}

    test "list_modalidades/0 returns all modalidades" do
      modalidade = modalidade_fixture()
      assert Modalidades.list_modalidades() == [modalidade]
    end

    test "get_modalidade!/1 returns the modalidade with given id" do
      modalidade = modalidade_fixture()
      assert Modalidades.get_modalidade!(modalidade.id) == modalidade
    end

    test "create_modalidade/1 with valid data creates a modalidade" do
      valid_attrs = %{
        ip: "some ip",
        localizacao: "some localizacao",
        nome: "some nome",
        porta: 42
      }

      assert {:ok, %Modalidade{} = modalidade} = Modalidades.create_modalidade(valid_attrs)
      assert modalidade.ip == "some ip"
      assert modalidade.localizacao == "some localizacao"
      assert modalidade.nome == "some nome"
      assert modalidade.porta == 42
    end

    test "create_modalidade/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Modalidades.create_modalidade(@invalid_attrs)
    end

    test "update_modalidade/2 with valid data updates the modalidade" do
      modalidade = modalidade_fixture()

      update_attrs = %{
        ip: "some updated ip",
        localizacao: "some updated localizacao",
        nome: "some updated nome",
        porta: 43
      }

      assert {:ok, %Modalidade{} = modalidade} =
               Modalidades.update_modalidade(modalidade, update_attrs)

      assert modalidade.ip == "some updated ip"
      assert modalidade.localizacao == "some updated localizacao"
      assert modalidade.nome == "some updated nome"
      assert modalidade.porta == 43
    end

    test "update_modalidade/2 with invalid data returns error changeset" do
      modalidade = modalidade_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Modalidades.update_modalidade(modalidade, @invalid_attrs)

      assert modalidade == Modalidades.get_modalidade!(modalidade.id)
    end

    test "delete_modalidade/1 deletes the modalidade" do
      modalidade = modalidade_fixture()
      assert {:ok, %Modalidade{}} = Modalidades.delete_modalidade(modalidade)
      assert_raise Ecto.NoResultsError, fn -> Modalidades.get_modalidade!(modalidade.id) end
    end

    test "change_modalidade/1 returns a modalidade changeset" do
      modalidade = modalidade_fixture()
      assert %Ecto.Changeset{} = Modalidades.change_modalidade(modalidade)
    end
  end
end

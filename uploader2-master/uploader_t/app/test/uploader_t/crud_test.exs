defmodule UploaderT.CRUDTest do
  use UploaderT.DataCase

  alias UploaderT.CRUD

  describe "modalities" do
    alias UploaderT.CRUD.Modality

    import UploaderT.CRUDFixtures

    @invalid_attrs %{ip: nil, location: nil, name: nil, port: nil}

    test "list_modalities/0 returns all modalities" do
      modality = modality_fixture()
      assert CRUD.list_modalities() == [modality]
    end

    test "get_modality!/1 returns the modality with given id" do
      modality = modality_fixture()
      assert CRUD.get_modality!(modality.id) == modality
    end

    test "create_modality/1 with valid data creates a modality" do
      valid_attrs = %{ip: "some ip", location: "some location", name: "some name", port: 42}

      assert {:ok, %Modality{} = modality} = CRUD.create_modality(valid_attrs)
      assert modality.ip == "some ip"
      assert modality.location == "some location"
      assert modality.name == "some name"
      assert modality.port == 42
    end

    test "create_modality/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = CRUD.create_modality(@invalid_attrs)
    end

    test "update_modality/2 with valid data updates the modality" do
      modality = modality_fixture()

      update_attrs = %{
        ip: "some updated ip",
        location: "some updated location",
        name: "some updated name",
        port: 43
      }

      assert {:ok, %Modality{} = modality} = CRUD.update_modality(modality, update_attrs)
      assert modality.ip == "some updated ip"
      assert modality.location == "some updated location"
      assert modality.name == "some updated name"
      assert modality.port == 43
    end

    test "update_modality/2 with invalid data returns error changeset" do
      modality = modality_fixture()
      assert {:error, %Ecto.Changeset{}} = CRUD.update_modality(modality, @invalid_attrs)
      assert modality == CRUD.get_modality!(modality.id)
    end

    test "delete_modality/1 deletes the modality" do
      modality = modality_fixture()
      assert {:ok, %Modality{}} = CRUD.delete_modality(modality)
      assert_raise Ecto.NoResultsError, fn -> CRUD.get_modality!(modality.id) end
    end

    test "change_modality/1 returns a modality changeset" do
      modality = modality_fixture()
      assert %Ecto.Changeset{} = CRUD.change_modality(modality)
    end
  end
end

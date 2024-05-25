defmodule UploaderG.EntitiesTest do
  use UploaderG.DataCase

  alias UploaderG.Entities

  describe "units" do
    alias UploaderG.Entities.Unit

    import UploaderG.EntitiesFixtures

    @invalid_attrs %{
      host: nil,
      location: nil,
      port: nil,
      public_key: nil,
      r_enabled: nil,
      t_enabled: nil
    }

    test "list_units/0 returns all units" do
      unit = unit_fixture()
      assert Entities.list_units() == [unit]
    end

    test "get_unit!/1 returns the unit with given id" do
      unit = unit_fixture()
      assert Entities.get_unit!(unit.id) == unit
    end

    test "create_unit/1 with valid data creates a unit" do
      valid_attrs = %{
        host: "some host",
        location: "some location",
        port: 42,
        public_key: "some public_key",
        r_enabled: true,
        t_enabled: true
      }

      assert {:ok, %Unit{} = unit} = Entities.create_unit(valid_attrs)
      assert unit.host == "some host"
      assert unit.location == "some location"
      assert unit.port == 42
      assert unit.public_key == "some public_key"
      assert unit.r_enabled == true
      assert unit.t_enabled == true
    end

    test "create_unit/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Entities.create_unit(@invalid_attrs)
    end

    test "update_unit/2 with valid data updates the unit" do
      unit = unit_fixture()

      update_attrs = %{
        host: "some updated host",
        location: "some updated location",
        port: 43,
        public_key: "some updated public_key",
        r_enabled: false,
        t_enabled: false
      }

      assert {:ok, %Unit{} = unit} = Entities.update_unit(unit, update_attrs)
      assert unit.host == "some updated host"
      assert unit.location == "some updated location"
      assert unit.port == 43
      assert unit.public_key == "some updated public_key"
      assert unit.r_enabled == false
      assert unit.t_enabled == false
    end

    test "update_unit/2 with invalid data returns error changeset" do
      unit = unit_fixture()
      assert {:error, %Ecto.Changeset{}} = Entities.update_unit(unit, @invalid_attrs)
      assert unit == Entities.get_unit!(unit.id)
    end

    test "delete_unit/1 deletes the unit" do
      unit = unit_fixture()
      assert {:ok, %Unit{}} = Entities.delete_unit(unit)
      assert_raise Ecto.NoResultsError, fn -> Entities.get_unit!(unit.id) end
    end

    test "change_unit/1 returns a unit changeset" do
      unit = unit_fixture()
      assert %Ecto.Changeset{} = Entities.change_unit(unit)
    end
  end
end

defmodule UploaderT.OperationTest do
  use UploaderT.DataCase

  alias UploaderT.Operation

  describe "transmissions" do
    alias UploaderT.Operation.Transmission

    import UploaderT.OperationFixtures

    @invalid_attrs %{file_path: nil, status: nil, uuid: nil}

    test "list_transmissions/0 returns all transmissions" do
      transmission = transmission_fixture()
      assert Operation.list_transmissions() == [transmission]
    end

    test "get_transmission!/1 returns the transmission with given id" do
      transmission = transmission_fixture()
      assert Operation.get_transmission!(transmission.id) == transmission
    end

    test "create_transmission/1 with valid data creates a transmission" do
      valid_attrs = %{file_path: "some file_path", status: :plain, uuid: "some uuid"}

      assert {:ok, %Transmission{} = transmission} = Operation.create_transmission(valid_attrs)
      assert transmission.file_path == "some file_path"
      assert transmission.is_not_sent == :plain
      assert transmission.uuid == "some uuid"
    end

    test "create_transmission/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Operation.create_transmission(@invalid_attrs)
    end

    test "update_transmission/2 with valid data updates the transmission" do
      transmission = transmission_fixture()
      update_attrs = %{file_path: "some updated file_path", status: :compressed, uuid: "some updated uuid"}

      assert {:ok, %Transmission{} = transmission} = Operation.update_transmission(transmission, update_attrs)
      assert transmission.file_path == "some updated file_path"
      assert transmission.is_not_sent == :compressed
      assert transmission.uuid == "some updated uuid"
    end

    test "update_transmission/2 with invalid data returns error changeset" do
      transmission = transmission_fixture()
      assert {:error, %Ecto.Changeset{}} = Operation.update_transmission(transmission, @invalid_attrs)
      assert transmission == Operation.get_transmission!(transmission.id)
    end

    test "delete_transmission/1 deletes the transmission" do
      transmission = transmission_fixture()
      assert {:ok, %Transmission{}} = Operation.delete_transmission(transmission)
      assert_raise Ecto.NoResultsError, fn -> Operation.get_transmission!(transmission.id) end
    end

    test "change_transmission/1 returns a transmission changeset" do
      transmission = transmission_fixture()
      assert %Ecto.Changeset{} = Operation.change_transmission(transmission)
    end
  end
end

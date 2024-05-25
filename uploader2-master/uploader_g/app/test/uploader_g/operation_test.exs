defmodule UploaderG.OperationTest do
  use UploaderG.DataCase

  alias UploaderG.Operation

  describe "transmissions" do
    alias UploaderG.Operation.Transmission

    import UploaderG.OperationFixtures

    @invalid_attrs %{
      checksum: nil,
      destination: nil,
      end: nil,
      origin: nil,
      size: nil,
      start: nil,
      status: nil,
      uuid: nil
    }

    test "list_transmissions/0 returns all transmissions" do
      transmission = transmission_fixture()
      assert Operation.list_transmissions() == [transmission]
    end

    test "get_transmission!/1 returns the transmission with given id" do
      transmission = transmission_fixture()
      assert Operation.get_transmission!(transmission.id) == transmission
    end

    test "create_transmission/1 with valid data creates a transmission" do
      valid_attrs = %{
        checksum: "some checksum",
        destination: "some destination",
        end: ~U[2022-02-10 14:39:00Z],
        origin: "some origin",
        size: 42,
        start: ~U[2022-02-10 14:39:00Z],
        status: "some status",
        uuid: "some uuid"
      }

      assert {:ok, %Transmission{} = transmission} = Operation.create_transmission(valid_attrs)
      assert transmission.checksum == "some checksum"
      assert transmission.destination == "some destination"
      assert transmission.end == ~U[2022-02-10 14:39:00Z]
      assert transmission.origin == "some origin"
      assert transmission.size == 42
      assert transmission.start == ~U[2022-02-10 14:39:00Z]
      assert transmission.status == "some status"
      assert transmission.uuid == "some uuid"
    end

    test "create_transmission/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Operation.create_transmission(@invalid_attrs)
    end

    test "update_transmission/2 with valid data updates the transmission" do
      transmission = transmission_fixture()

      update_attrs = %{
        checksum: "some updated checksum",
        destination: "some updated destination",
        end: ~U[2022-02-11 14:39:00Z],
        origin: "some updated origin",
        size: 43,
        start: ~U[2022-02-11 14:39:00Z],
        status: "some updated status",
        uuid: "some updated uuid"
      }

      assert {:ok, %Transmission{} = transmission} =
               Operation.update_transmission(transmission, update_attrs)

      assert transmission.checksum == "some updated checksum"
      assert transmission.destination == "some updated destination"
      assert transmission.end == ~U[2022-02-11 14:39:00Z]
      assert transmission.origin == "some updated origin"
      assert transmission.size == 43
      assert transmission.start == ~U[2022-02-11 14:39:00Z]
      assert transmission.status == "some updated status"
      assert transmission.uuid == "some updated uuid"
    end

    test "update_transmission/2 with invalid data returns error changeset" do
      transmission = transmission_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Operation.update_transmission(transmission, @invalid_attrs)

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

defmodule UploaderG.LoggingTest do
  use UploaderG.DataCase

  alias UploaderG.Logging

  describe "logs" do
    alias UploaderG.Logging.Log

    import UploaderG.LoggingFixtures

    @invalid_attrs %{event: nil, logged_at: nil, message: nil, uuid: nil}

    test "list_logs/0 returns all logs" do
      log = log_fixture()
      assert Logging.list_logs() == [log]
    end

    test "get_log!/1 returns the log with given id" do
      log = log_fixture()
      assert Logging.get_log!(log.id) == log
    end

    test "create_log/1 with valid data creates a log" do
      valid_attrs = %{
        event: "some event",
        logged_at: ~U[2022-02-10 14:47:00Z],
        message: "some message",
        uuid: "some uuid"
      }

      assert {:ok, %Log{} = log} = Logging.create_log(valid_attrs)
      assert log.event == "some event"
      assert log.logged_at == ~U[2022-02-10 14:47:00Z]
      assert log.message == "some message"
      assert log.uuid == "some uuid"
    end

    test "create_log/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Logging.create_log(@invalid_attrs)
    end

    test "update_log/2 with valid data updates the log" do
      log = log_fixture()

      update_attrs = %{
        event: "some updated event",
        logged_at: ~U[2022-02-11 14:47:00Z],
        message: "some updated message",
        uuid: "some updated uuid"
      }

      assert {:ok, %Log{} = log} = Logging.update_log(log, update_attrs)
      assert log.event == "some updated event"
      assert log.logged_at == ~U[2022-02-11 14:47:00Z]
      assert log.message == "some updated message"
      assert log.uuid == "some updated uuid"
    end

    test "update_log/2 with invalid data returns error changeset" do
      log = log_fixture()
      assert {:error, %Ecto.Changeset{}} = Logging.update_log(log, @invalid_attrs)
      assert log == Logging.get_log!(log.id)
    end

    test "delete_log/1 deletes the log" do
      log = log_fixture()
      assert {:ok, %Log{}} = Logging.delete_log(log)
      assert_raise Ecto.NoResultsError, fn -> Logging.get_log!(log.id) end
    end

    test "change_log/1 returns a log changeset" do
      log = log_fixture()
      assert %Ecto.Changeset{} = Logging.change_log(log)
    end
  end
end

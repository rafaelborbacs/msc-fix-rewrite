defmodule UploaderG.LoggingFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `UploaderG.Logging` context.
  """

  @doc """
  Generate a log.
  """
  def log_fixture(attrs \\ %{}) do
    {:ok, log} =
      attrs
      |> Enum.into(%{
        event: "some event",
        logged_at: ~U[2022-02-10 14:47:00Z],
        message: "some message",
        uuid: "some uuid"
      })
      |> UploaderG.Logging.create_log()

    log
  end
end

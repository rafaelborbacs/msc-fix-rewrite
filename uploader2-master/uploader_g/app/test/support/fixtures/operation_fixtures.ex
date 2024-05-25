defmodule UploaderG.OperationFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `UploaderG.Operation` context.
  """

  @doc """
  Generate a transmission.
  """
  def transmission_fixture(attrs \\ %{}) do
    {:ok, transmission} =
      attrs
      |> Enum.into(%{
        checksum: "some checksum",
        destination: "some destination",
        end: ~U[2022-02-10 14:39:00Z],
        origin: "some origin",
        size: 42,
        start: ~U[2022-02-10 14:39:00Z],
        status: "some status",
        uuid: "some uuid"
      })
      |> UploaderG.Operation.create_transmission()

    transmission
  end
end

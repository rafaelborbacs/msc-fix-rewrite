defmodule UploaderT.OperationFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `UploaderT.Operation` context.
  """

  @doc """
  Generate a transmission.
  """
  def transmission_fixture(attrs \\ %{}) do
    {:ok, transmission} =
      attrs
      |> Enum.into(%{
        file_path: "some file_path",
        status: :plain,
        uuid: "some uuid"
      })
      |> UploaderT.Operation.create_transmission()

    transmission
  end
end

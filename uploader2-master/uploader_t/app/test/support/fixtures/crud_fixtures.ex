defmodule UploaderT.CRUDFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `UploaderT.CRUD` context.
  """

  @doc """
  Generate a modality.
  """
  def modality_fixture(attrs \\ %{}) do
    {:ok, modality} =
      attrs
      |> Enum.into(%{
        ip: "some ip",
        location: "some location",
        name: "some name",
        port: 42
      })
      |> UploaderT.CRUD.create_modality()

    modality
  end
end

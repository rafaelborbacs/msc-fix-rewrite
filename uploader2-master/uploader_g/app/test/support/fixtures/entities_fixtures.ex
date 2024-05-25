defmodule UploaderG.EntitiesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `UploaderG.Entities` context.
  """

  @doc """
  Generate a unit.
  """
  def unit_fixture(attrs \\ %{}) do
    {:ok, unit} =
      attrs
      |> Enum.into(%{
        host: "some host",
        location: "some location",
        port: 42,
        public_key: "some public_key",
        r_enabled: true,
        t_enabled: true
      })
      |> UploaderG.Entities.create_unit()

    unit
  end
end

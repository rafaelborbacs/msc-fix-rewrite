defmodule UploaderG.UnidadesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `UploaderG.Unidades` context.
  """

  @doc """
  Generate a unidade.
  """
  def unidade_fixture(attrs \\ %{}) do
    {:ok, unidade} =
      attrs
      |> Enum.into(%{
        chave_publica: "some chave_publica",
        ip: "some ip",
        localizacao: "some localizacao",
        porta: 42
      })
      |> UploaderG.Unidades.create_unidade()

    unidade
  end
end

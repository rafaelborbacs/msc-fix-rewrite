defmodule UploaderT.ModalidadesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `UploaderT.Modalidades` context.
  """

  @doc """
  Generate a modalidade.
  """
  def modalidade_fixture(attrs \\ %{}) do
    {:ok, modalidade} =
      attrs
      |> Enum.into(%{
        ip: "some ip",
        localizacao: "some localizacao",
        nome: "some nome",
        porta: 42
      })
      |> UploaderT.Modalidades.create_modalidade()

    modalidade
  end
end

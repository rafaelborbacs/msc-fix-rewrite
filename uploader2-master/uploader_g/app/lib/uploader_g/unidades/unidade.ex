defmodule UploaderG.Unidades.Unidade do
  use Ecto.Schema
  import Ecto.Changeset

  schema "unidades" do
    field :chave_publica, :string
    field :ip, :string
    field :localizacao, :string
    field :porta, :integer

    timestamps()
  end

  @doc false
  def changeset(unidade, attrs) do
    unidade
    |> cast(attrs, [:localizacao, :ip, :porta, :chave_publica])
    |> validate_required([:localizacao, :ip, :porta, :chave_publica])
  end
end

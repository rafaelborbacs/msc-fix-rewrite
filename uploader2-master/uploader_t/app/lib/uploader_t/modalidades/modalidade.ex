defmodule UploaderT.Modalidades.Modalidade do
  use Ecto.Schema
  import Ecto.Changeset

  schema "modalidades" do
    field :ip, :string
    field :localizacao, :string
    field :nome, :string
    field :porta, :integer

    timestamps()
  end

  @doc false
  def changeset(modalidade, attrs) do
    modalidade
    |> cast(attrs, [:nome, :localizacao, :ip, :porta])
    |> validate_required([:nome, :localizacao, :ip, :porta])
  end
end

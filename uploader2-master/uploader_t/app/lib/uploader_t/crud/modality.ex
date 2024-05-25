defmodule UploaderT.CRUD.Modality do
  use Ecto.Schema
  import Ecto.Changeset

  schema "modalities" do
    field :ip, :string
    field :location, :string
    field :name, :string
    field :port, :integer
    field :ae_title, :string

    timestamps()
  end

  @doc false
  def changeset(modality, attrs) do
    modality
    |> cast(attrs, [:name, :location, :ip, :port, :ae_title])
    |> validate_required([:name, :location, :ip, :port, :ae_title])
  end
end

defmodule UploaderG.Operation.Transmission do
  use Ecto.Schema
  import Ecto.Changeset

  schema "transmissions" do
    field :checksum, :string
    field :destination, :string
    field :end, :utc_datetime
    field :origin, :string
    field :size, :integer
    field :start, :utc_datetime
    field :status, :string
    field :uuid, :string
    field :study_instance_uid, :string
    field :study_description, :string

    timestamps()
  end

  @doc false
  def changeset(transmission, attrs) do
    transmission
    |> cast(attrs, [
      :uuid,
      :size,
      :origin,
      :destination,
      :start,
      :end,
      :status,
      :checksum,
      :study_instance_uid,
      :study_description
    ])
    |> unique_constraint(:uuid)
    |> validate_required([:uuid])
  end
end

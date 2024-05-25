defmodule UploaderT.Operation.Transmission do
  use Ecto.Schema
  import Ecto.Changeset

  schema "transmissions" do
    field(:file_path, :string)
    field(:sent, :boolean)
    field(:uuid, :string)
    field(:study_instance_uid, :string)
    field(:study_description, :string)

    timestamps()
  end

  @doc false
  def changeset(transmission, attrs) do
    transmission
    |> cast(
      attrs,
      [
        :uuid,
        :file_path,
        :sent,
        :study_instance_uid,
        :study_description
      ]
    )
    |> validate_required([:uuid, :file_path, :sent])
  end
end

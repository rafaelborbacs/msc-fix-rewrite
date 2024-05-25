defmodule UploaderG.Logging.Log do
  use Ecto.Schema
  import Ecto.Changeset

  schema "logs" do
    field :event, :string
    field :logged_at, :utc_datetime
    field :message, :string
    field :uuid, :string
    field :unit_id, :id
    field :transmission_id, :id
    field :origin, :string

    timestamps()
  end

  @doc false
  def changeset(log, attrs) do
    log
    |> cast(attrs, [:uuid, :logged_at, :event, :message, :unit_id, :transmission_id, :origin])
    |> validate_required([:logged_at, :event, :message])
  end
end

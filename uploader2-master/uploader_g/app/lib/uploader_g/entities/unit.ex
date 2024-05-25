defmodule UploaderG.Entities.Unit do
  use Ecto.Schema
  import Ecto.Changeset

  schema "units" do
    field :host, :string
    field :location, :string
    field :port, :integer
    field :public_key, :string
    field :public_key_identifier, :string
    field :r_enabled, :boolean, default: false
    field :t_enabled, :boolean, default: false
    field :authorized, :boolean, default: false
    field :receiver_accepted, :boolean, default: false
    field :transmits_to, :string
    field :status, :boolean, default: true
    field :new, :boolean, default: true
    field :processing_timeout, :integer
    field :sync_timeout, :integer
    field :store_timeout, :integer

    timestamps()
  end

  @doc false
  def changeset(unit, attrs) do
    unit
    |> cast(attrs, [
      :location,
      :host,
      :port,
      :public_key,
      :public_key_identifier,
      :r_enabled,
      :t_enabled,
      :authorized,
      :receiver_accepted,
      :transmits_to,
      :status,
      :new,
      :processing_timeout,
      :sync_timeout,
      :store_timeout
    ])
    |> validate_required([:public_key, :public_key_identifier])
    |> unique_constraint(:public_key)
    |> unique_constraint(:public_key_identifier)
  end
end

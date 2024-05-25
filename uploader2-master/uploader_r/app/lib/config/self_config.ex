defmodule UploaderR.Config.SelfConfig do
  use Ecto.Schema
  import Ecto.Changeset

  @derive {Jason.Encoder, except: [:__meta__]}

  schema "self_config" do
    field :manager_host, :string
    field :manager_port, :integer
    field :repository_ae_title, :string
    field :self_ae_title, :string
    field :host, :string
    field :port, :integer
    field :uuid, :string
    field :location, :string
    field :store_timeout, :integer
    field :processing_timeout, :integer
    timestamps()
  end

  @doc false
  def changeset(self_config, attrs) do
    self_config
    |> cast(attrs, [:manager_host, :uuid, :manager_port, :repository_ae_title, :self_ae_title, :host, :port, :location, :store_timeout, :processing_timeout])
    |> validate_required([:manager_host, :uuid, :manager_port, :repository_ae_title, :self_ae_title, :host, :port, :location, :store_timeout, :processing_timeout])
    # |> validate_length(:repository_ae_title, min: 1, max: 16)
    # |> validate_length(:self_ae_title, min: 1, max: 16)
  end
end

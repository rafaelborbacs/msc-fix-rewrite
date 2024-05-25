defmodule UploaderT.Config.SourceConfig do
  use Ecto.Schema
  import Ecto.Changeset

  @derive {Jason.Encoder, except: [:__meta__]}

  schema "source_config" do
    field :ae_title, :string
    field :ip, :string
    field :port, :integer
    field :location, :string
    field :limit, :integer
    field :sync_timeout, :integer
    field :processing_timeout, :integer

    timestamps()
  end

  @doc false
  def changeset(source_config, attrs) do
    source_config
    |> cast(attrs, [:ae_title, :ip, :port, :location, :limit, :sync_timeout, :processing_timeout])
    |> validate_required([:ae_title, :ip, :port, :location, :sync_timeout, :processing_timeout])
    |> validate_length(:ae_title, min: 1, max: 16)
  end
end

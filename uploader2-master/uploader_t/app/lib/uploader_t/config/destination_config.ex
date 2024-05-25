defmodule UploaderT.Config.DestinationConfig do
  use Ecto.Schema
  import Ecto.Changeset

  @derive {Jason.Encoder, except: [:__meta__]}

  schema "destination_config" do
    field :ip, :string
    field :port, :integer
    field :uuid, :string

    timestamps()
  end

  @doc false
  def changeset(source_config, attrs) do
    source_config
    |> cast(attrs, [:ip, :port, :uuid])
    |> validate_required([:ip, :port, :uuid])
  end
end

defmodule UploaderG.Repo.Migrations.CreateTransmissions do
  use Ecto.Migration

  def change do
    create table(:transmissions) do
      add :uuid, :string
      add :size, :integer
      add :origin, :string
      add :destination, :string
      add :start, :utc_datetime
      add :end, :utc_datetime
      add :status, :string
      add :checksum, :string

      timestamps()
    end
  end
end

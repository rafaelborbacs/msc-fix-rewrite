defmodule UploaderG.Repo.Migrations.CreateLogs do
  use Ecto.Migration

  def change do
    create table(:logs) do
      add :uuid, :string
      add :logged_at, :utc_datetime
      add :event, :string
      add :message, :string
      add :unit_id, references(:units, on_delete: :nothing)

      timestamps()
    end

    create index(:logs, [:unit_id])
  end
end

defmodule UploaderT.Repo.Migrations.CreateTransmissions do
  use Ecto.Migration

  def change do
    create table(:transmissions) do
      add :uuid, :string
      add :file_path, :string
      add :status, :string

      timestamps()
    end
  end
end

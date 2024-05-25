defmodule UploaderG.Repo.Migrations.AddStatusField do
  use Ecto.Migration

  def change do
    alter table(:units) do
      add :status, :boolean
    end
  end
end

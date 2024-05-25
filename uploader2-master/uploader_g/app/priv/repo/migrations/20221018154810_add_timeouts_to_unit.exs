defmodule UploaderG.Repo.Migrations.AddTimeoutsToUnit do
  use Ecto.Migration

  def change do
    alter table(:units) do
      add :processing_timeout, :integer
      add :sync_timeout, :integer
      add :store_timeout, :integer
    end
  end
end

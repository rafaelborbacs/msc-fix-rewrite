defmodule UploaderG.Repo.Migrations.AddNewToUnit do
  use Ecto.Migration

  def change do
    alter table(:units) do
      add(:new, :boolean, default: true)
    end
  end
end

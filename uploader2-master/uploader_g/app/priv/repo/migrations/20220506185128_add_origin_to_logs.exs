defmodule UploaderG.Repo.Migrations.AddOriginToLogs do
  use Ecto.Migration

  def change do
    alter table(:logs) do
      add :origin, :text
    end
  end
end

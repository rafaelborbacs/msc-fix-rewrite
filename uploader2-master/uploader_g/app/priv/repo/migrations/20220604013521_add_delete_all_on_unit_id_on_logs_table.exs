defmodule UploaderG.Repo.Migrations.AddDeleteAllOnUnitIdOnLogsTable do
  use Ecto.Migration

  def change do
    drop_if_exists constraint(:logs, :logs_unit_id_fkey)

    alter table(:logs) do
      modify :unit_id, references(:units, on_delete: :delete_all)
    end
  end
end

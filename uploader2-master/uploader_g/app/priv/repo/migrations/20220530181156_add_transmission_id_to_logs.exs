defmodule UploaderG.Repo.Migrations.AddTransmissionIdToLogs do
  use Ecto.Migration

  def change do
    alter table(:logs) do
      add :transmission_id, references(:transmissions, on_delete: :nothing)
    end
  end
end

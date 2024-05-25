defmodule UploaderG.Repo.Migrations.AddStudyInstanceUidColumnOnTransmission do
  use Ecto.Migration

  def change do
    alter table(:transmissions) do
      add :study_instance_uid, :string
    end
  end
end

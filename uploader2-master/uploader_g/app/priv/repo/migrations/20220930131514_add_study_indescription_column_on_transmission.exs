defmodule UploaderG.Repo.Migrations.AddStudyIndescriptionColumnOnTransmission do
  use Ecto.Migration

  def change do
    alter table(:transmissions) do
      add :study_description, :string
    end
  end
end

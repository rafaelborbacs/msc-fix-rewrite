defmodule UploaderT.Repo.Migrations.AddIsNotSentFieldForTransmission do
  use Ecto.Migration

  def change do
    alter table(:transmissions) do
      add :is_not_sent, :boolean
    end
  end
end

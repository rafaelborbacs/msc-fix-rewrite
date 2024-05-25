defmodule UploaderT.Repo.Migrations.RemoveStatusFieldFromTransmission do
  use Ecto.Migration

  def change do
    alter table(:transmissions) do
      remove :status
    end
  end
end

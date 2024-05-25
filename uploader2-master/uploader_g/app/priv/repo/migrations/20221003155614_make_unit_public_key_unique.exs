defmodule UploaderG.Repo.Migrations.MakeUnitPublicKeyUnique do
  use Ecto.Migration

  def change do
    create unique_index(:units, [:public_key])
  end
end

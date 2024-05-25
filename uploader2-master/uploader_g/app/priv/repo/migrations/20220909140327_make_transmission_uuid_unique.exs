defmodule UploaderG.Repo.Migrations.MakeTransmissionUuidUnique do
  use Ecto.Migration

  def change do
    create unique_index(:transmissions, [:uuid])
  end
end

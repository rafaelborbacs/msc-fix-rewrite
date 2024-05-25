defmodule UploaderG.Repo.Migrations.AddTransmitsToField do
  use Ecto.Migration

  def change do
    alter table(:units) do
      add :transmits_to, :string
    end
  end
end

defmodule UploaderG.Repo.Migrations.AddAuthorizedField do
  use Ecto.Migration

  def change do
    alter table(:units) do
      add :authorized, :boolean
    end
  end
end

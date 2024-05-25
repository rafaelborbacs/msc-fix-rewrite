defmodule UploaderG.Repo.Migrations.CreateUnits do
  use Ecto.Migration

  def change do
    create table(:units) do
      add :location, :string
      add :host, :string
      add :port, :integer
      add :public_key, :string
      add :r_enabled, :boolean, default: false, null: false
      add :t_enabled, :boolean, default: false, null: false

      timestamps()
    end
  end
end

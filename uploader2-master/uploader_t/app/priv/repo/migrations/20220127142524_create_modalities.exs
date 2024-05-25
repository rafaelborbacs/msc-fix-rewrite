defmodule UploaderT.Repo.Migrations.CreateModalities do
  use Ecto.Migration

  def change do
    create table(:modalities) do
      add :name, :string
      add :location, :string
      add :ip, :string
      add :port, :integer

      timestamps()
    end
  end
end

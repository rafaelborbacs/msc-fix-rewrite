defmodule UploaderG.Repo.Migrations.CreateUnidades do
  use Ecto.Migration

  def change do
    create table(:unidades) do
      add :localizacao, :string
      add :ip, :string
      add :porta, :integer
      add :chave_publica, :string

      timestamps()
    end
  end
end

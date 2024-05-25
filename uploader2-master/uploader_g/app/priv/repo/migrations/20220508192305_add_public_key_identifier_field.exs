defmodule UploaderG.Repo.Migrations.AddPublicKeyIdentifierField do
  use Ecto.Migration

  def change do
    alter table(:units) do
      add :public_key_identifier, :string
    end
  end
end

defmodule UploaderG.Repo.Migrations.ChangePublicKeyStringToText do
  use Ecto.Migration

  def change do
    alter table(:units) do
      modify :public_key, :text, from: :string
    end
  end
end

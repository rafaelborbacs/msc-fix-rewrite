defmodule UploaderT.Repo.Migrations.AddAeTitleFieldOnModality do
  use Ecto.Migration

  def change do
    alter table(:modalities) do
      add :ae_title, :string
    end
  end
end

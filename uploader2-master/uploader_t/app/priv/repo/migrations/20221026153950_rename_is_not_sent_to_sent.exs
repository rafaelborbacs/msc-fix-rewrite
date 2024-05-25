defmodule UploaderT.Repo.Migrations.RenameIsNotSentToSent do
  use Ecto.Migration

  def change do
    rename table(:transmissions), :is_not_sent, to: :sent
  end
end

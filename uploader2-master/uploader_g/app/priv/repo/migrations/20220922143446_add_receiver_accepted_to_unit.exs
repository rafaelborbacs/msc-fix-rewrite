defmodule UploaderG.Repo.Migrations.AddReceiverAcceptedToUnit do
  use Ecto.Migration

  def change do
    alter table(:units) do
      add(:receiver_accepted, :boolean, default: false)
    end
  end
end

defmodule RewardService.Repo.Migrations.CreateWallets do
  use Ecto.Migration

  def change do
    create table(:wallets, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :user_id, references(:users, type: :binary_id, on_delete: :delete_all), null: false
      add :balance_points, :integer, default: 0, null: false
      # virtual wallet in KES
      add :balance_ksh, :decimal, default: 0, null: false
      timestamps()
    end

    create unique_index(:wallets, [:user_id])
  end
end

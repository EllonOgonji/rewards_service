defmodule RewardService.Repo.Migrations.CreateTransactions do
  use Ecto.Migration

  def change do
    create table(:transactions, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :user_id, references(:users, type: :binary_id), null: false
      # "earn" | "redeem"
      add :type, :string, null: false
      add :points, :integer, null: false
      # e.g. "purchase", "referral", "signup"
      add :reason, :string, null: false
      add :metadata, :map, default: %{}
      add :status, :string, default: "completed"
      timestamps()
    end

    create index(:transactions, [:user_id])
    create index(:transactions, [:type])
  end
end

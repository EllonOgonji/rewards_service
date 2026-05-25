defmodule RewardService.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :email, :string, null: false
      add :name, :string, null: false
      add :api_key_hash, :string
      timestamps()
    end

    create unique_index(:users, [:email])
  end
end

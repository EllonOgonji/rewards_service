defmodule RewardsService.Wallet.Wallet do
  @moduledoc """
  Schema for the wallets table — each user has one wallet
  tracking their points balance and KES credit.
  """
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}

  schema "wallets" do
    field :balance_points, :integer, default: 0
    field :balance_ksh, :decimal, default: Decimal.new("0")

    belongs_to :user, RewardsService.Accounts.User, type: :binary_id

    timestamps()
  end

  def changeset(wallet, attrs) do
    wallet
    |> cast(attrs, [:user_id, :balance_points, :balance_ksh])
    |> validate_required([:user_id])
    |> validate_number(:balance_points, greater_than_or_equal_to: 0)
    |> unique_constraint(:user_id)
  end
end

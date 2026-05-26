defmodule RewardsService.Factory do
  use ExMachina.Ecto, repo: RewardsService.Repo

  alias RewardsService.Accounts.User
  alias RewardsService.Wallet.Wallet
  alias RewardsService.Rewards.Transaction

  def user_factory do
    %User{
      name: sequence(:name, &"User #{&1}"),
      email: sequence(:email, &"user#{&1}@example.com"),
      api_key_hash: "testhash"
    }
  end

  def wallet_factory do
    %Wallet{
      user: build(:user),
      balance_points: 0,
      balance_ksh: Decimal.new("0")
    }
  end

  def transaction_factory do
    %Transaction{
      user: build(:user),
      type: "earn",
      points: 100,
      reason: "signup",
      metadata: %{}
    }
  end
end

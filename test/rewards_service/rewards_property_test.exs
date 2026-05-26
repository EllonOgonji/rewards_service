defmodule RewardsService.RewardsPropertyTest do
  use ExUnit.Case, async: true
  use ExUnitProperties
  import RewardsService.Factory
  alias RewardsService.{Rewards, Wallet}

  # We need to explicitly setup the Ecto Sandbox since we are not using DataCase
  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(RewardsService.Repo)
    Ecto.Adapters.SQL.Sandbox.mode(RewardsService.Repo, {:shared, self()})
  end

  property "points earned are always positive" do
    check all amount <- integer(10..100_000) do
      user = insert(:user)
      insert(:wallet, user: user)

      {:ok, txn} = Rewards.earn_points(user.id, "purchase", %{"amount_ksh" => amount})
      assert txn.points > 0
    end
  end

  property "wallet balance never goes negative after valid redemption" do
    check all pts <- integer(1..500) do
      user = insert(:user)
      insert(:wallet, user: user, balance_points: 1000)

      Rewards.redeem_points(user.id, pts)
      {:ok, wallet} = Wallet.get_balance(user.id)
      assert wallet.balance_points >= 0
    end
  end
end

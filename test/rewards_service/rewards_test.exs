# test/rewards_service/rewards_test.exs
defmodule RewardsService.RewardsTest do
  use RewardsService.DataCase, async: true
  alias RewardsService.{Rewards, Accounts, Wallet}

  setup do
    {:ok, user} = Accounts.create_user(%{email: "test@example.com", name: "Kamau"})
    {:ok, _wallet} = Wallet.create_for_user(user.id)
    %{user: user}
  end

  describe "earn_points/3" do
    test "awards correct points for purchase", %{user: user} do
      {:ok, txn} = Rewards.earn_points(user.id, "purchase", %{"amount_ksh" => 500})
      assert txn.points == 50
      assert txn.type == "earn"
    end

    test "awards flat points for signup", %{user: user} do
      {:ok, txn} = Rewards.earn_points(user.id, "signup")
      assert txn.points == 100
    end

    test "increments wallet balance", %{user: user} do
      Rewards.earn_points(user.id, "signup")
      {:ok, wallet} = Wallet.get_balance(user.id)
      assert wallet.balance_points == 100
    end
  end

  describe "redeem_points/2" do
    test "redeems points and credits KES wallet", %{user: user} do
      # 250 pts
      Rewards.earn_points(user.id, "referral")
      {:ok, txn} = Rewards.redeem_points(user.id, 200)

      assert txn.type == "redeem"
      assert txn.points == 200
      {:ok, wallet} = Wallet.get_balance(user.id)
      assert wallet.balance_points == 50
      assert Decimal.compare(wallet.balance_ksh, Decimal.new("100.0")) == :eq
    end

    test "returns error when insufficient points", %{user: user} do
      assert {:error, :insufficient_points} = Rewards.redeem_points(user.id, 999)
    end
  end
end

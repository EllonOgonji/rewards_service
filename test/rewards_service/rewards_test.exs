defmodule RewardsService.RewardsTest do
  use RewardsService.DataCase, async: true
  import RewardsService.Factory

  alias RewardsService.{Rewards, Wallet}

  setup do
    user = insert(:user)
    insert(:wallet, user: user, balance_points: 0)
    %{user: user}
  end

  describe "earn_points/3 — point calculation" do
    test "purchase: 1 point per KES 10", %{user: user} do
      {:ok, txn} = Rewards.earn_points(user.id, "purchase", %{"amount_ksh" => 500})
      assert txn.points == 50
    end

    test "signup gives 100 flat points", %{user: user} do
      {:ok, txn} = Rewards.earn_points(user.id, "signup")
      assert txn.points == 100
    end

    test "referral gives 250 flat points", %{user: user} do
      {:ok, txn} = Rewards.earn_points(user.id, "referral")
      assert txn.points == 250
    end

    test "wallet balance is updated atomically", %{user: user} do
      Rewards.earn_points(user.id, "signup")
      Rewards.earn_points(user.id, "referral")
      {:ok, wallet} = Wallet.get_balance(user.id)
      assert wallet.balance_points == 350
    end

    test "returns error for invalid reason", %{user: user} do
      assert {:error, changeset} = Rewards.earn_points(user.id, "made_up_reason")
      assert "is invalid" in errors_on(changeset).reason
    end
  end

  describe "redeem_points/2" do
    setup %{user: user} do
      Rewards.earn_points(user.id, "referral")  # seeds 250 points
      :ok
    end

    test "deducts points and credits KES wallet", %{user: user} do
      {:ok, txn} = Rewards.redeem_points(user.id, 200)
      assert txn.type == "redeem"
      assert txn.points == 200

      {:ok, wallet} = Wallet.get_balance(user.id)
      assert wallet.balance_points == 50
      # 200 pts × KES 0.50 = KES 100
      assert Decimal.compare(wallet.balance_ksh, Decimal.new("100.0")) == :eq
    end

    test "blocks redemption when points are insufficient", %{user: user} do
      assert {:error, :insufficient_points} = Rewards.redeem_points(user.id, 9999)
    end

    test "exact balance redemption succeeds", %{user: user} do
      assert {:ok, _} = Rewards.redeem_points(user.id, 250)
      {:ok, wallet} = Wallet.get_balance(user.id)
      assert wallet.balance_points == 0
    end

    test "zero balance after full redemption cannot redeem again", %{user: user} do
      Rewards.redeem_points(user.id, 250)
      assert {:error, :insufficient_points} = Rewards.redeem_points(user.id, 1)
    end
  end

  describe "list_transactions/2" do
    test "returns paginated results", %{user: user} do
      for _ <- 1..25, do: Rewards.earn_points(user.id, "signup")

      page1 = Rewards.list_transactions(user.id, page: 1, per_page: 20)
      page2 = Rewards.list_transactions(user.id, page: 2, per_page: 20)

      assert length(page1) == 20
      assert length(page2) == 5
    end
  end
end

defmodule RewardsService.Rewards do
  import Ecto.Query
  alias RewardsService.{Repo, Wallet}
  alias RewardsService.Rewards.Transaction

  # 1 point = 0.5 KSH
  @points_to_ksh_rate Decimal.new("0.5")

  @doc "Award points based on criteria (e.g. purchase amount)"
  def earn_points(user_id, reason, metadata \\ %{}) do
    points = calculate_points(reason, metadata)

    changeset = Transaction.changeset(%Transaction{}, %{
      user_id: user_id,
      type: "earn",
      points: points,
      reason: reason,
      metadata: metadata
    })

    Ecto.Multi.new()
    |> Ecto.Multi.insert(:transaction, changeset)
    |> Ecto.Multi.run(:wallet, fn repo, _ ->
      Wallet.increment_points(repo, user_id, points)
    end)
    |> Repo.transaction()
    |> case do
      {:ok, %{transaction: txn}} ->
        invalidate_cache(user_id)
        broadcast_event("points_earned", %{user_id: user_id, points: points})
        {:ok, txn}

      {:error, _op, changeset, _} ->
        {:error, changeset}
    end
  end

  @doc "Redeem points — converts to KES wallet credit"
  def redeem_points(user_id, points_to_redeem) do
    with {:ok, balance} <- Wallet.get_balance(user_id),
         :ok <- check_sufficient_points(balance.balance_points, points_to_redeem) do
      ksh_credit = Decimal.mult(points_to_redeem, @points_to_ksh_rate)

      changeset = Transaction.changeset(%Transaction{}, %{
        user_id: user_id,
        type: "redeem",
        points: points_to_redeem,
        reason: "redemption",
        metadata: %{ksh_credited: ksh_credit}
      })

      Ecto.Multi.new()
      |> Ecto.Multi.insert(:transaction, changeset)
      |> Ecto.Multi.run(:wallet, fn repo, _ ->
        Wallet.deduct_points_and_credit_ksh(repo, user_id, points_to_redeem, ksh_credit)
      end)
      |> Repo.transaction()
      |> case do
        {:ok, %{transaction: txn}} ->
          invalidate_cache(user_id)
          broadcast_event("points_redeemed", %{user_id: user_id, ksh: ksh_credit})
          {:ok, txn}

        {:error, _op, changeset, _} ->
          {:error, changeset}
      end
    end
  end

  def list_transactions(user_id, opts \\ []) do
    page = Keyword.get(opts, :page, 1)
    per_page = Keyword.get(opts, :per_page, 20)

    Transaction
    |> where([t], t.user_id == ^user_id)
    |> order_by([t], desc: t.inserted_at)
    |> limit(^per_page)
    |> offset(^((page - 1) * per_page))
    |> Repo.all()
  end

  # --- Private ---

  # Points assignment criteria (your own business rules)
  defp calculate_points("purchase", %{"amount_ksh" => amount}) do
    # 1 point per KES 10 spent
    trunc(amount / 10)
  end

  defp calculate_points("signup", _), do: 100
  defp calculate_points("referral", _), do: 250
  defp calculate_points("promotion", %{"points" => p}), do: p
  defp calculate_points(_, _), do: 10

  defp check_sufficient_points(balance, requested) when balance >= requested, do: :ok
  defp check_sufficient_points(_, _), do: {:error, :insufficient_points}

  defp invalidate_cache(user_id) do
    Cachex.del(:rewards_cache, "wallet:#{user_id}")
  end

  defp broadcast_event(event, payload) do
    Phoenix.PubSub.broadcast(
      RewardsService.PubSub,
      "rewards:#{payload.user_id}",
      {event, payload}
    )
  end
end

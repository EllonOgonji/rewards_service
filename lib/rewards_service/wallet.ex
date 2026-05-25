defmodule RewardsService.Wallet do
  alias RewardsService.{Repo, Wallet.Wallet}
  import Ecto.Query

  def get_balance(user_id) do
    Cachex.fetch(:rewards_cache, "wallet:#{user_id}", fn ->
      case Repo.get_by(Wallet, user_id: user_id) do
        nil -> {:error, :not_found}
        wallet -> {:commit, wallet}
      end
    end)
    |> case do
      {:ok, wallet} -> {:ok, wallet}
      {:commit, wallet} -> {:ok, wallet}
      {:error, _} = err -> err
    end
  end

  def increment_points(repo, user_id, points) do
    {1, [wallet]} =
      from(w in Wallet, where: w.user_id == ^user_id, select: w)
      |> repo.update_all(inc: [balance_points: points])

    {:ok, wallet}
  end

  def deduct_points_and_credit_ksh(repo, user_id, points, ksh) do
    {1, [wallet]} =
      from(w in Wallet, where: w.user_id == ^user_id, select: w)
      |> repo.update_all(
        inc: [balance_points: -points, balance_ksh: ksh]
      )

    {:ok, wallet}
  end

  def create_for_user(user_id) do
    %Wallet{user_id: user_id}
    |> Wallet.changeset(%{})
    |> Repo.insert()
  end
end

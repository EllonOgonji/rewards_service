defmodule RewardsService.Workers.PointsWorker do
  use Oban.Worker, queue: :rewards, max_attempts: 3

  alias RewardsService.Rewards

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"user_id" => user_id, "reason" => reason, "metadata" => meta}}) do
    case Rewards.earn_points(user_id, reason, meta) do
      {:ok, _txn} -> :ok
      {:error, reason} -> {:error, reason}
    end
  end
end

# Enqueue like this:
# %{user_id: user.id, reason: "purchase", metadata: %{"amount_ksh" => 500}}
# |> RewardsService.Workers.PointsWorker.new()
# |> Oban.insert()

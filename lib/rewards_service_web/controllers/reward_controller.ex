defmodule RewardsServiceWeb.RewardController do
  use RewardsServiceWeb, :controller
  use PhoenixSwagger

  alias RewardsService.Rewards

  swagger_path :earn do
    post("/api/v1/users/{id}/points/earn")
    summary("Award points to a user")
    parameter(:id, :path, :string, "User ID", required: true)
    parameter(:body, :body, Schema.ref(:EarnPointsRequest), "Earn request", required: true)
    response(200, "Points awarded", Schema.ref(:TransactionResponse))
    response(422, "Validation error")
  end

  def earn(conn, %{"id" => user_id, "reason" => reason} = params) do
    metadata = Map.get(params, "metadata", %{})

    case Rewards.earn_points(user_id, reason, metadata) do
      {:ok, txn} ->
        conn
        |> put_status(:ok)
        |> json(%{
          data: %{
            id: txn.id,
            type: txn.type,
            points: txn.points,
            reason: txn.reason,
            status: txn.status,
            inserted_at: txn.inserted_at
          }
        })

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{errors: format_errors(changeset)})
    end
  end

  def redeem(conn, %{"id" => user_id, "points" => points}) do
    case Rewards.redeem_points(user_id, points) do
      {:ok, txn} ->
        conn
        |> put_status(:ok)
        |> json(%{
          data: %{
            id: txn.id,
            type: txn.type,
            points: txn.points,
            reason: txn.reason,
            status: txn.status,
            inserted_at: txn.inserted_at
          }
        })

      {:error, :insufficient_points} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{error: "insufficient points balance"})

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{errors: format_errors(changeset)})
    end
  end

  def transactions(conn, %{"id" => user_id} = params) do
    opts = [
      page: String.to_integer(Map.get(params, "page", "1")),
      per_page: String.to_integer(Map.get(params, "per_page", "20"))
    ]

    txns = Rewards.list_transactions(user_id, opts)

    conn
    |> put_status(:ok)
    |> json(%{
      data:
        Enum.map(txns, fn txn ->
          %{
            id: txn.id,
            type: txn.type,
            points: txn.points,
            reason: txn.reason,
            status: txn.status,
            metadata: txn.metadata,
            inserted_at: txn.inserted_at
          }
        end)
    })
  end

  defp format_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Regex.replace(~r"%{(\w+)}", msg, fn _, key ->
        opts |> Keyword.get(String.to_existing_atom(key), key) |> to_string()
      end)
    end)
  end
end

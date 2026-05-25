defmodule RewardsServiceWeb.WalletController do
  use RewardsServiceWeb, :controller

  alias RewardsService.Wallet

  def show(conn, %{"id" => user_id}) do
    case Wallet.get_balance(user_id) do
      {:ok, wallet} ->
        conn
        |> put_status(:ok)
        |> json(%{
          data: %{
            id: wallet.id,
            user_id: wallet.user_id,
            balance_points: wallet.balance_points,
            balance_ksh: wallet.balance_ksh,
            updated_at: wallet.updated_at
          }
        })

      {:error, :not_found} ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "wallet not found"})
    end
  end
end

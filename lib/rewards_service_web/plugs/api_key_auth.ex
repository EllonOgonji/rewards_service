defmodule RewardsServiceWeb.Plugs.ApiKeyAuth do
  import Plug.Conn
  alias RewardsService.Accounts

  def init(opts), do: opts

  def call(conn, _opts) do
    with ["Bearer " <> key] <- get_req_header(conn, "authorization"),
         {:ok, user} <- Accounts.get_user_by_api_key(key) do
      assign(conn, :current_user, user)
    else
      _ ->
        conn
        |> put_status(:unauthorized)
        |> Phoenix.Controller.json(%{error: "invalid or missing API key"})
        |> halt()
    end
  end
end

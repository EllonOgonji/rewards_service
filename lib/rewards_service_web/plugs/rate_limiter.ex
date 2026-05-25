defmodule RewardsServiceWeb.Plugs.RateLimiter do
  import Plug.Conn

  # 100 requests per minute per user
  @scale_ms 60_000
  @limit 100

  def init(opts), do: opts

  def call(conn, _opts) do
    user_id = conn.assigns[:current_user].id
    bucket = "user:#{user_id}"

    case Hammer.check_rate(bucket, @scale_ms, @limit) do
      {:allow, count} ->
        conn
        |> put_resp_header("x-ratelimit-limit", "#{@limit}")
        |> put_resp_header("x-ratelimit-remaining", "#{@limit - count}")

      {:deny, _limit} ->
        conn
        |> put_status(:too_many_requests)
        |> Phoenix.Controller.json(%{error: "rate limit exceeded"})
        |> halt()
    end
  end
end

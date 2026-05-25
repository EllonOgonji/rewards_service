defmodule RewardsServiceWeb.Plugs.RequestLogger do
  @moduledoc """
  Plug that logs incoming API requests with relevant metadata.
  """
  require Logger

  def init(opts), do: opts

  def call(conn, _opts) do
    start_time = System.monotonic_time()

    Plug.Conn.register_before_send(conn, fn conn ->
      duration = System.monotonic_time() - start_time
      duration_ms = System.convert_time_unit(duration, :native, :millisecond)

      Logger.info(
        "method=#{conn.method} path=#{conn.request_path} " <>
          "status=#{conn.status} duration=#{duration_ms}ms"
      )

      conn
    end)
  end
end

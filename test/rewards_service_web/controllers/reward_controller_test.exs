defmodule RewardsServiceWeb.RewardControllerTest do
  use RewardsServiceWeb.ConnCase, async: true
  import RewardsService.Factory

  setup do
    user = insert(:user, api_key_hash: hash("test-api-key"))
    insert(:wallet, user: user)
    conn = build_conn() |> put_req_header("authorization", "Bearer test-api-key")
    %{user: user, conn: conn}
  end

  describe "POST /api/v1/users/:id/points/earn" do
    test "awards points and returns transaction", %{conn: conn, user: user} do
      body = %{reason: "signup"}
      resp = conn |> post("/api/v1/users/#{user.id}/points/earn", body) |> json_response(200)

      assert resp["data"]["type"] == "earn"
      assert resp["data"]["points"] == 100
    end

    test "returns 422 for invalid reason", %{conn: conn, user: user} do
      resp = conn |> post("/api/v1/users/#{user.id}/points/earn", %{reason: "nonsense"}) |> json_response(422)
      assert resp["errors"]["reason"]
    end

    test "returns 401 without API key" do
      resp =
        build_conn()
        |> post("/api/v1/users/some-id/points/earn", %{reason: "signup"})
        |> json_response(401)

      assert resp["error"] =~ "invalid"
    end
  end

  describe "POST /api/v1/users/:id/points/redeem" do
    setup %{user: user} do
      RewardsService.Rewards.earn_points(user.id, "referral")  # 250 pts
      :ok
    end

    test "redeems points successfully", %{conn: conn, user: user} do
      resp = conn |> post("/api/v1/users/#{user.id}/points/redeem", %{points: 100}) |> json_response(200)
      assert resp["data"]["type"] == "redeem"
    end

    test "returns 422 when balance is too low", %{conn: conn, user: user} do
      resp = conn |> post("/api/v1/users/#{user.id}/points/redeem", %{points: 9999}) |> json_response(422)
      assert resp["error"] == "insufficient points balance"
    end
  end

  # helper
  defp hash(key), do: :crypto.hash(:sha256, key) |> Base.encode16(case: :lower)
end

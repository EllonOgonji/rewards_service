defmodule RewardsServiceWeb.Router do
  use RewardsServiceWeb, :router

  import Phoenix.LiveDashboard.Router

  pipeline :api do
    plug :accepts, ["json"]
    plug RewardsServiceWeb.Plugs.ApiKeyAuth
    plug RewardsServiceWeb.Plugs.RateLimiter
    plug RewardsServiceWeb.Plugs.RequestLogger
  end

  scope "/api/v1", RewardsServiceWeb do
    pipe_through :api

    resources "/users", UserController, only: [:create, :show]
    get "/users/:id/wallet", WalletController, :show
    post "/users/:id/points/earn", RewardController, :earn
    post "/users/:id/points/redeem", RewardController, :redeem
    get "/users/:id/transactions", RewardController, :transactions
  end

  scope "/dashboard" do
    pipe_through [:fetch_session, :protect_from_forgery]
    live_dashboard "/", metrics: RewardsServiceWeb.Telemetry
  end

  scope "/api/swagger" do
    forward "/", PhoenixSwagger.Plug.SwaggerUI,
      otp_app: :rewards_service,
      swagger_file: "swagger.json"
  end
end

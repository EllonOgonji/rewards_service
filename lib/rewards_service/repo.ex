defmodule RewardsService.Repo do
  use Ecto.Repo,
    otp_app: :rewards_service,
    adapter: Ecto.Adapters.Postgres
end

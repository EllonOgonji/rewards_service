defmodule RewardsService.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      RewardsServiceWeb.Telemetry,
      RewardsService.Repo,
      {DNSCluster, query: Application.get_env(:rewards_service, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: RewardsService.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: RewardsService.Finch},
      # Cachex cache for wallet balances
      {Cachex, name: :rewards_cache},
      # Oban for background job processing
      {Oban, Application.fetch_env!(:rewards_service, Oban)},
      # Start to serve requests, typically the last entry
      RewardsServiceWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: RewardsService.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    RewardsServiceWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end

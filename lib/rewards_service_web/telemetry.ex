defmodule RewardsServiceWeb.Telemetry do
  use Supervisor
  import Telemetry.Metrics

  def start_link(arg), do: Supervisor.start_link(__MODULE__, arg, name: __MODULE__)

  def init(_arg) do
    children = [
      {:telemetry_poller, measurements: periodic_measurements(), period: 10_000}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end

  def metrics do
    [
      counter("rewards_service.points.earned.count"),
      sum("rewards_service.points.earned.total"),
      counter("rewards_service.points.redeemed.count"),
      sum("rewards_service.ksh.credited.total"),
      summary("phoenix.endpoint.stop.duration", unit: {:native, :millisecond}),
      counter("phoenix.router_dispatch.stop.count"),
      last_value("vm.memory.total", unit: :byte),
      last_value("vm.total_run_queue_lengths.total")
    ]
  end

  defp periodic_measurements, do: []
end

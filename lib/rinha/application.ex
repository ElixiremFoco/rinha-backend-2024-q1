defmodule Rinha.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    topologies = [
      example: [
        strategy: Cluster.Strategy.Epmd,
        config: [hosts: [:"rinha@#{host_ip()}", :"rinha@#{node_ip()}"]],
      ]
    ]

    children =
      [
        Rinha.Repo,
        {Cluster.Supervisor, [topologies, [name: Rinha.ClusterSupervisor]]},
        RinhaWeb.Endpoint
      ] ++
        if(master_node?(), do: [Rinha.Producer], else: [])

    # ++
    # [
    #   Supervisor.child_spec(Rinha.Consumer, id: :consumer_1),
    #   Supervisor.child_spec(Rinha.Consumer, id: :consumer_2),
    #   Supervisor.child_spec(Rinha.Consumer, id: :consumer_3)
    # ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Rinha.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    RinhaWeb.Endpoint.config_change(changed, removed)
    :ok
  end

  defp host_ip, do: System.fetch_env!("IP_V4_ADDRESS")
  defp node_ip, do: System.fetch_env!("IP_NODE")
  defp master_node?, do: String.ends_with?(host_ip(), "11")
end

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
        config: [hosts: [:"rinha@#{host_ip()}", :"rinha@#{node_ip()}"]]
      ]
    ]

    children =
      [
        Rinha.Repo,
        Rinha.CustomerLimits,
        # Commanded application
        Rinha.CMD.Application,
        # {Horde.Registry, [name: Rinha.Registry, keys: :unique, members: registry_members()]},
        # {Horde.DynamicSupervisor,
        # name: Rinha.HordeSupervisor, strategy: :one_for_one, members: supervisor_members()},
        # {Cluster.Supervisor, [topologies, [name: Rinha.ClusterSupervisor]]},
        RinhaWeb.Endpoint
        # connector_child_spec()
      ]

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

  defp registry_members do
    [
      {Rinha.Registry, :"rinha@#{host_ip()}"},
      {Rinha.Registry, :"rinha@#{node_ip()}"}
    ]
  end

  defp supervisor_members do
    [
      {Rinha.HordeSupervisor, :"rinha@#{host_ip()}"},
      {Rinha.HordeSupervisor, :"rinha@#{node_ip()}"}
    ]
  end

  defp connector_child_spec do
    %{
      id: Rinha.ClusterConnector,
      restart: :transient,
      start:
        {Task, :start_link,
         [
           fn ->
             Horde.DynamicSupervisor.wait_for_quorum(Rinha.HordeSupervisor, 30_000)
             Horde.DynamicSupervisor.start_child(Rinha.HordeSupervisor, Rinha.Producer)

             if host_ip() == node_ip() do
               Horde.DynamicSupervisor.start_child(
                 Rinha.HordeSupervisor,
                 Supervisor.child_spec(Rinha.Consumer, id: :consumer_1)
               )

               Horde.DynamicSupervisor.start_child(
                 Rinha.HordeSupervisor,
                 Supervisor.child_spec(Rinha.Consumer, id: :consumer_2)
               )
             else
               Horde.DynamicSupervisor.start_child(
                 Rinha.HordeSupervisor,
                 Supervisor.child_spec(Rinha.Consumer, id: :consumer_3)
               )

               Horde.DynamicSupervisor.start_child(
                 Rinha.HordeSupervisor,
                 Supervisor.child_spec(Rinha.Consumer, id: :consumer_4)
               )
             end
           end
         ]}
    }
  end
end

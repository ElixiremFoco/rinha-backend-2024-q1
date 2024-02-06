defmodule RinhaWeb.Healthcheck do
  @moduledoc """
  Plug que computa dinamicamente a saúde do serviço
  """

  import Plug.Conn

  alias Rinha.Repo

  @behaviour Plug

  @impl true
  def init(opts), do: opts

  @impl true
  def call(conn, _opts) do
    case Repo.query("select 1;") do
      {:ok, _} -> send_resp(conn, :ok, "")
      {:error, _} -> send_resp(conn, :service_unavailable, "")
    end
  end
end

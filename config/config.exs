import Config

config :rinha,
  ecto_repos: [Rinha.Repo],
  event_stores: [Rinha.EventStore],
  generators: [timestamp_type: :utc_datetime]

# Configures the endpoint
config :rinha, RinhaWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [json: RinhaWeb.ErrorJSON],
    layout: false
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"

# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :elc,
  ecto_repos: [Elc.Repo]

# Configures the endpoint
config :elc, ElcWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "VStqVj49SCK2NyYJFRB3NGdrOlWRfFOM1PAvtCsjWJmpx9orx7coY39f/T00Slts",
  render_errors: [view: ElcWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: Elc.PubSub,
  live_view: [signing_salt: "8PkC+hDX"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"

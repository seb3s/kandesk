# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :kandesk,
  ecto_repos: [Kandesk.Repo]

# Configures the endpoint
config :kandesk, KandeskWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "O8I0j9p1IXJUi65h5S73INz0qDzLxQ3pfIcCR9Y3BjMmWGXhlcJFTFfDRMbHpHr7",
  render_errors: [view: KandeskWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Kandesk.PubSub, adapter: Phoenix.PubSub.PG2],
  live_view: [signing_salt: "5BFoIPvCG/CUh9GwpXNBIC2qh/JUB/Z5"]


config :kandesk, :pow,
  user: Kandesk.Schema.User,
  repo: Kandesk.Repo,
  web_module: KandeskWeb,
  extensions: [PowResetPassword, PowPersistentSession],
  controller_callbacks: Pow.Extension.Phoenix.ControllerCallbacks,
  mailer_backend: Kandesk.Mailer,
  web_mailer_module: KandeskWeb

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"

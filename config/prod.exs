import Config

# Unused (no static files)
# config :uro, Uro.Endpoint, cache_static_manifest: "priv/static/cache_manifest.json"

# Do not print debug messages in production.

config :uro, Uro.Mailer, adapter: Swoosh.Adapters.Local

config :logger, level: :info

use Mix.Config

# Set default Revisionair storage adapter.
config :revisionair, storage: RevisionairEcto

# Repos known to Ecto:
config :revisionair_ecto, ecto_repos: [RevisionairEcto.Repo]
# Default repo used by RevisionairEcto:
config :revisionair_ecto, repo: RevisionairEcto.Repo

# Test Repo settings
config :revisionair_ecto, RevisionairEcto.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "postgres",
  database: "revisionair_ecto_test",
  hostname: "localhost",
  poolsize: 10,
  # Ensure async testing is possible:
  pool: Ecto.Adapters.SQL.Sandbox

defmodule RevisionairEcto.Repo do
  use Ecto.Repo, otp_app: :revisionair_ecto,
                 adapter: Ecto.Adapters.Postgres
end

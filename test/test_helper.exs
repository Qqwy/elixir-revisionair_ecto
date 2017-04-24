defmodule RevisionairEcto.Repo do
  use Ecto.Repo, otp_app: :revisionair_ecto
end

Mix.Task.run "ecto.create", ~w(-r RevisionairEcto.Repo)
Mix.Task.run "ecto.migrate", ~w(-r RevisionairEcto.Repo)

Application.put_env(:revisionair_ecto, repo: RevisionairEcto.Repo)

{:ok, _pid} = TestWhatwasit.Repo.start_link


ExUnit.start()


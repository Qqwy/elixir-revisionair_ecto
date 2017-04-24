# defmodule RevisionairEcto.Repo do
#   use Ecto.Repo, otp_app: :revisionair_ecto
# end

defmodule Post do
  use Ecto.Schema

  schema "posts" do
    field :title, :string
    field :content, :string
  end
end

Mix.Task.run "ecto.create", ~w(-r RevisionairEcto.Repo)
Mix.Task.run "ecto.migrate", ~w(-r RevisionairEcto.Repo)

# Application.put_env(:revisionair_ecto, repo: RevisionairEcto.Repo)

{:ok, _pid} = RevisionairEcto.Repo.start_link


ExUnit.start()


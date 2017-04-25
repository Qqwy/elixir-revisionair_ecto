# defmodule RevisionairEcto.Repo do
#   use Ecto.Repo, otp_app: :revisionair_ecto
# end

# To test normal ID workings.
defmodule Post do
  use Ecto.Schema

  schema "posts" do
    field :title, :string
    field :content, :string
  end
end

# To test workings with UUID
defmodule UUIDPost do
  use Ecto.Schema

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "uuid_posts" do
    field :title, :string
    field :content, :string
  end
end


Mix.Task.run "ecto.drop", ~w(-r RevisionairEcto.Repo)
Mix.Task.run "ecto.create", ~w(-r RevisionairEcto.Repo)
Mix.Task.run "ecto.migrate", ~w(-r RevisionairEcto.Repo)

{:ok, _pid} = RevisionairEcto.Repo.start_link
Ecto.Adapters.SQL.Sandbox.mode(RevisionairEcto.Repo, :manual)

# Application.put_env(:revisionair_ecto, repo: RevisionairEcto.Repo)

ExUnit.start()


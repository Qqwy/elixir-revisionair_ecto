defmodule RevisionairEcto.Repo.Migrations.PostsUuid do
  use Ecto.Migration

  # Example data table to be used during testing with UUIDs.
  def change do
    create table(:uuid_posts, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :content, :text
      add :title, :string
    end
  end
end

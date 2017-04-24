defmodule RevisionairEcto.Repo.Migrations.Posts do
  use Ecto.Migration
  # Example data table to be used during testing.
  def change do
    create table(:posts) do
      add :content, :text
      add :title, :string
    end
  end
end

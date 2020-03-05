defmodule RevisionairEcto.Repo.Migrations.Comments do
  use Ecto.Migration
  # Example data table to be used during testing.
  def change do
    create table(:comments) do
      add :post_id, :integer
      add :content, :text
    end
  end
end

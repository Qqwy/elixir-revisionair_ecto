defmodule RevisionairEcto.Repo.Migrations.RevisionsTable do
  use Ecto.Migration

  def change do
    create table(:revisions) do
      add :item_type, :string, null: false
      add :item_id, :integer, null: false
      add :item_map, :map, null: false
      add :metadata, :map, null: false
      add :revision, :integer, null: false
    end

    create index(:revisions, [:item_type, :item_id])
  end
end

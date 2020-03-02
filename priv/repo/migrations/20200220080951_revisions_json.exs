defmodule RevisionairEcto.Repo.Migrations.RevisionsJson do
  use Ecto.Migration

  # Example migration for the revisions table, using JSON `encoded_item`s.
  def change do
    create table(:json_revisions) do
      add :item_type, :string, null: false
      add :item_id, :integer, null: false
      add :encoded_item, :json, null: false
      add :metadata, :map, null: false
      add :revision, :integer, null: false
      add :struct_name, :string
    end

    create index(:json_revisions, [:item_type, :item_id])
    create unique_index(:json_revisions, [:item_type, :item_id, :revision])
  end

end

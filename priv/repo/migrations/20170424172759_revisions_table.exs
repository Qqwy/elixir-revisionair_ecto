defmodule RevisionairEcto.Repo.Migrations.RevisionsTable do
  use Ecto.Migration

  def change do
    create table(:revisions) do
      add :item_type, :string, null: false
      # If you want to use UUIDs instead, alter the following line to
      # add :item_id, :uuid, null: false
      add :item_id, :integer, null: false
      add :encoded_item, :binary, null: false
      add :metadata, :map, null: false
      add :revision, :integer, null: false
      add :struct_name, :string
    end

    create index(:revisions, [:item_type, :item_id])
    create unique_index(:revisions, [:item_type, :item_id, :revision])
  end
end

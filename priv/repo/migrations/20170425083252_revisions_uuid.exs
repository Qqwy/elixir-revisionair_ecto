defmodule RevisionairEcto.Repo.Migrations.RevisionsUuid do
  use Ecto.Migration

  def change do
    create table(:uuid_revisions) do
      add :item_type, :string, null: false
      add :item_id, :uuid, null: false
      add :encoded_item, :binary, null: false
      add :metadata, :map, null: false
      add :revision, :integer, null: false
      add :struct_name, :string
    end

    create index(:uuid_revisions, [:item_type, :item_id])
    create unique_index(:uuid_revisions, [:item_type, :item_id, :revision])
  end

end

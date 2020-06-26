defmodule RevisionairEcto.Repo.Migrations.RevisionsTable do
  use Ecto.Migration

  # Example migration for the revisions table, using numerical `item_id`s.
  def change do
    create table(:revisions, primary_key: false) do
      add :item_type, :string, null: false
      # If you want to use UUIDs instead, alter the following line to
      # add :item_id, :uuid, null: false
      add :item_id, :integer, null: false
      add :encoded_item, :binary, null: false
      add :metadata, :map, null: false
      add :revision, :integer, null: false
    end

    create unique_index(:revisions, [:item_type, :item_id, :revision])
  end
end

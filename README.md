# RevisionairEcto

A [Revisionair](https://github.com/Qqwy/elixir_revisionair) adapter based on [Ecto](https://github.com/elixir-ecto/ecto). Allows you to persist and keep track of revisions of your data structures in any of Ecto's supported databases.

The things that you want to keep track of do _not_ necessarily need to be (Ecto-backed) models/schemas. _Any_ data structure can be used (even things that are not structs).

## Installation

First, install the library by adding `revisionair_ecto` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [{:revisionair_ecto, "~> 1.0.0"}]
end
```

Then, create a migration (`mix ecto.gen.migration revisions_table`) akin to the following:

```elixir

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
```

Finally, in your `config/config.exs`, add the following lines to configure Revisonair and RevisionairEcto:


```elixir
# Set default Revisionair storage adapter.
config :revisionair, storage: RevisionairEcto

# Default repo used by RevisionairEcto:
config :revisionair_ecto, repo: RevisionairEcto.Repo

# Uncomment if you use UUIDs instead of numerical ids:
# config :revisionair_ecto, item_id_type: :uuid

# Uncomment if you use a different table than "revisions" to store the revisions information:
# config :revisionair_ecto, revisions_table: "table_name"
```

Of course, any of these settings can also be specified in the `options` parameter when calling any of the Revisionair functions:

```elixir

Revisionair.store_revision(my_post, [storage: RevisionairEcto, storage_options: [repo: MyOtherRepo, revisions_table: "my_revisions", item_id_type: :uuid]])

```

(This also allows overriding certain settings only in certain special locations.)

## Usage

The functions in this module should not be used directly, rather, the functions that the [Revisionair](https://github.com/Qqwy/elixir_revisionair) module exposes should be used.

As these function calls will hit the database directly, make sure that especially `store_revision` is used within a Repo transaction to ensure that the revision is only stored if the other database operations could be performed successfully.

Example: 
```elixir

{:ok, post} = Repo.transaction fn ->
  post = Repo.insert!(%Post{title: "Test", content: "Lorem ipsum"})
  :ok = Revisionair.store_revision(post, Post, post.id)
  post
end

Revisionair.newest_revision(post)
Revisionair.list_revisions(post)
Revisionair.get_revision(post, 0)
```

## Changelog

- 1.0.2 Removes superfluous and noisy logging call.
- 1.0.1 Updates Revisionair version.
- 1.0.0 First Stable Version.

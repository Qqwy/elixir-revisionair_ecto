defmodule RevisionairEctoTest do
  use ExUnit.Case, async: true
  doctest RevisionairEcto

  alias RevisionairEcto.Repo


  defmodule TestStruct do
    defstruct id: 0, foo: 1, bar: 2
  end

  setup do
    # Explicitly get a connection before each test
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Repo)
  end


  test "Simple flow using test RevisionairEcto" do
    f1 = %TestStruct{id: 1, foo: 0}
    f1b = %TestStruct{f1 | foo: 2, bar: 3}

    assert Revisionair.store_revision(f1, [storage: RevisionairEcto]) == :ok
    assert Revisionair.store_revision(f1b, [storage: RevisionairEcto]) == :ok
    assert Revisionair.list_revisions(f1b, [storage: RevisionairEcto]) == [{f1b, %{revision: 1}},
                                                                                          {f1, %{revision: 0}}]
    assert Revisionair.delete_all_revisions_of(f1b, [storage: RevisionairEcto]) == :ok
    assert Revisionair.list_revisions(f1b, [storage: RevisionairEcto]) == []
    assert Revisionair.list_revisions(f1, [storage: RevisionairEcto]) == []

  end

  test "explicit structure_type and unique_identifier using RevisionairEcto" do
    f1 = %TestStruct{id: 1, foo: 0}
    f1b = %TestStruct{f1 | foo: 2, bar: 3}

    assert Revisionair.store_revision(f1, TestStruct, 1, [storage: RevisionairEcto]) == :ok
    assert Revisionair.store_revision(f1b, [storage: RevisionairEcto]) == :ok
    assert Revisionair.list_revisions(TestStruct, 1, [storage: RevisionairEcto]) == [{f1b, %{revision: 1}},
                                                                                                   {f1, %{revision: 0}}]
  end

  test "get_revision using RevisionairEcto" do
    f1 = %TestStruct{id: 1, foo: 0}
    f1b = %TestStruct{f1 | foo: 2, bar: 3}

    Revisionair.store_revision(f1, [storage: RevisionairEcto])
    Revisionair.store_revision(f1b, [storage: RevisionairEcto])

    assert Revisionair.get_revision(f1b, 1, [storage: RevisionairEcto]) == \
    {:ok, {%TestStruct{bar: 3, foo: 2, id: 1}, %{revision: 1}}}
    assert Revisionair.get_revision(f1b, 0, [storage: RevisionairEcto]) == \
    {:ok, {%TestStruct{bar: 2, foo: 0, id: 1}, %{revision: 0}}}
  end

  test "normal ID integration" do
    {:ok, post} = Repo.transaction fn ->
      post = Repo.insert!(%Post{title: "Test", content: "Lorem ipsum"})
      :ok = Revisionair.store_revision(post, Post, post.id)
      post
    end

    assert Repo.all(Post) != []
    assert Revisionair.get_revision(post, 0) == {:ok, {post, %{revision: 0}}}
    assert Revisionair.newest_revision(post) == {:ok, {post, %{revision: 0}}}
    assert Revisionair.list_revisions(post) == [{post, %{revision: 0}}]
    assert Revisionair.delete_all_revisions_of(post) == :ok
    assert Revisionair.list_revisions(post) == []
  end

  test "UUID integration" do
    # Application.put_env(:revisionair_ecto, :revisions_table, "uuid_revisions")

    {:ok, post} = Repo.transaction fn ->
      post = Repo.insert!(%UUIDPost{title: "Test", content: "Lorem ipsum"})
      :ok = Revisionair.store_revision(post, UUIDPost, post.id, storage_options: [revisions_table: "uuid_revisions", item_id_type: :uuid])
      post
    end

    assert Repo.all(UUIDPost) != []
    assert Revisionair.get_revision(post, 0, storage_options: [revisions_table: "uuid_revisions", item_id_type: :uuid]) == {:ok, {post, %{revision: 0}}}
    assert Revisionair.newest_revision(post, storage_options: [revisions_table: "uuid_revisions", item_id_type: :uuid]) == {:ok, {post, %{revision: 0}}}
    assert Revisionair.list_revisions(post, storage_options: [revisions_table: "uuid_revisions", item_id_type: :uuid]) == [{post, %{revision: 0}}]
    assert Revisionair.delete_all_revisions_of(post, storage_options: [revisions_table: "uuid_revisions", item_id_type: :uuid]) == :ok
    assert Revisionair.list_revisions(post, storage_options: [revisions_table: "uuid_revisions", item_id_type: :uuid]) == []
  end

end

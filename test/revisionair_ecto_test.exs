defmodule RevisionairEctoTest do
  use ExUnit.Case
  doctest RevisionairEcto

  test "the truth" do
    RevisionairEcto.Repo.insert_all("posts", [[title: "1"]])
    assert 1 + 1 == 2
  end


  defmodule TestStruct do
    defstruct id: 0, foo: 1, bar: 2
  end


  test "Simple flow using test Revision.Storage.Agent" do
    f1 = %TestStruct{id: 1, foo: 0}
    f1b = %TestStruct{f1 | foo: 2, bar: 3}

    assert Revisionair.store_revision(f1, [storage: RevisionairEcto]) == :ok
    assert Revisionair.store_revision(f1b, [storage: RevisionairEcto]) == :ok
    assert Revisionair.list_revisions(f1b, [storage: RevisionairEcto]) == [{f1b, %{revision: 1}},
                                                                                          {f1, %{revision: 0}}]
    assert Revisionair.delete_all_revisions_of(f1b, [storage: RevisionairEcto]) == :ok
    assert Revisionair.list_revisions(f1b, [storage: RevisionairEcto]) == []
    assert Revisionair.list_revisions(f1, [storage: RevisionairEcto]) == []

    Repo.delete_all("revisions")
  end

  test "explicit structure_type and unique_identifier with Revision.Storage.Agent" do
    f1 = %TestStruct{id: 1, foo: 0}
    f1b = %TestStruct{f1 | foo: 2, bar: 3}

    assert Revisionair.store_revision(f1, TestStruct, 1, [storage: RevisionairEcto]) == :ok
    assert Revisionair.store_revision(f1b, [storage: RevisionairEcto]) == :ok
    assert Revisionair.list_revisions(TestStruct, 1, [storage: RevisionairEcto]) == [{f1b, %{revision: 1}},
                                                                                                   {f1, %{revision: 0}}]
    Repo.delete_all("revisions")
  end

  test "get_revision" do
    f1 = %TestStruct{id: 1, foo: 0}
    f1b = %TestStruct{f1 | foo: 2, bar: 3}

    Revisionair.store_revision(f1, [storage: RevisionairEcto])
    Revisionair.store_revision(f1b, [storage: RevisionairEcto])

    assert Revisionair.get_revision(f1b, 1, [storage: RevisionairEcto]) == \
    {:ok, {%TestStruct{bar: 3, foo: 2, id: 1}, %{revision: 1}}}
    assert Revisionair.get_revision(f1b, 0, [storage: RevisionairEcto]) == \
    {:ok, {%TestStruct{bar: 2, foo: 0, id: 1}, %{revision: 0}}}

    Repo.delete_all("revisions")
  end
end

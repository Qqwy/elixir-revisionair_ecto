defmodule RevisionairEctoTest do
  use ExUnit.Case
  doctest RevisionairEcto

  test "the truth" do
    RevisionairEcto.Repo.insert_all("posts", [[title: "1"]])
    assert 1 + 1 == 2
  end
end

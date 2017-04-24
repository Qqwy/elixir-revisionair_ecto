defmodule RevisionairEcto do
  @moduledoc """
  Ecto adapter of the Revisionair.Storage behaviour.

  TODO How to get Repo?
  """

  import Ecto.Query

  def store_revision(item, item_type, item_id, metadata, options) do
    repo = extract_repo(options)
    item_type = to_string item_type

    repo.insert_all("revisions", [%{
                                   item_type: item_type,
                                   item_id: item_id,
                                   item_map: item,
                                   metadata: metadata,
                                   revision: next_revision(item_type, item_id, repo)
                                 }])
  end

  def list_revisions(item_type, item_id, options) do
    repo = extract_repo(options)
    item_type = to_string item_type

    repo.all(from r in "revisions", where: r.item_type == ^item_type and r.item_id == ^item_id, select: {r.revision, {r.item_map, r.metadata}}, order_by: [desc: :revision])
    |> Enum.map(fn {revision, {item, metadata}} -> put_revision_in_metadata({item, metadata}, revision) end)
  end

  def newest_revision(item_type, item_id, options) do
    repo = extract_repo(options)
    item_type = to_string item_type

    case repo.all(from r in "revisions", where: r.item_type == ^item_type and r.item_id == ^item_id, limit: 1, order_by: [desc: :revision], select: {r.revision, {r.item_map, r.metadata}}) do
      [] -> :error
      [{revision, {data, metadata}}] -> {:ok, put_revision_in_metadata({data, metadata}, revision)}
    end
  end

  def get_revision(item_type, item_id, revision, options) do
      repo = extract_repo(options)
      item_type = to_string item_type

    case repo.all(from r in "revisions", where: r.item_type == ^item_type and r.item_id == ^item_id and r.revision == ^revision, limit: 1, select: {r.revision, {r.item_map, r.metadata}}) do
      [] -> :error
      [{revision, {data, metadata}}] -> {:ok, put_revision_in_metadata({data, metadata}, revision)}
    end
  end

  def delete_all_revisions_of(item_type, item_id, options) do
    repo = extract_repo(options)
    item_type = to_string item_type

    repo.delete_all(from r in "revisions", where: r.item_type == ^item_type and r.item_id == ^item_id)
    :ok
  end

  defp extract_repo(options) do
    options[:repo] || Application.fetch_env!(:revisionair_ecto, :repo)
  end


  defp put_revision_in_metadata({item, metadata}, revision) do
    {item, Map.put(metadata, :revision, revision)}
  end

  defp next_revision(item_type, item_id, repo) do
    case repo.all(from r in "revisions", where: r.item_type == ^item_type and r.item_id == ^item_id, select: r.revision, limit: 1, order_by: [desc: :revision]) do
      [] -> 0
      [num] -> num + 1
    end
  end
end

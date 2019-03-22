defmodule RevisionairEcto do
  @moduledoc """
  Ecto adapter of the Revisionair.Storage behaviour.

  See `Revisionair` itself for documentation on how to use it.
  """

  import Ecto.Query

  @doc false
  def store_revision(item, item_type, item_id, metadata, options) do
    repo = extract_repo(options)
    item_type = to_string item_type
    revisions_table = extract_table_name(options)
    item_id_type = item_id_type(options)
    encoded_item_id = encode_item_id(item_id, item_id_type)

    {1, _} = repo.insert_all(revisions_table, [%{
                                   item_type: item_type,
                                   item_id: encoded_item_id,
                                   encoded_item: encode_item(item),
                                   metadata: metadata,
                                   revision: next_revision(item_type, item_id, repo, revisions_table, item_id_type)
                                 }])
    :ok
  end

  @doc false
  def list_revisions(item_type, item_id, options) do
    repo = extract_repo(options)
    item_type = to_string item_type
    revisions_table = extract_table_name(options)
    item_id_type = item_id_type(options)

    repo.all(from r in revisions_table, where: r.item_type == ^item_type and r.item_id == type(^item_id, ^item_id_type), select: {r.revision, {r.encoded_item, r.metadata}}, order_by: [desc: :revision])
    |> Enum.map(fn {revision, {item, metadata}} -> put_revision_in_metadata({decode_item(item), metadata}, revision) end)
  end

  @doc false
  def newest_revision(item_type, item_id, options) do
    repo = extract_repo(options)
    item_type = to_string item_type
    revisions_table = extract_table_name(options)
    item_id_type = item_id_type(options)


    case repo.all(
          from r in revisions_table,
          where: r.item_type == ^item_type and r.item_id == type(^item_id, ^item_id_type),
          limit: 1,
          order_by: [desc: :revision],
          select: {r.revision, {r.encoded_item, r.metadata}}
        ) do
      [] -> :error
      [{revision, {item, metadata}}] -> {:ok, put_revision_in_metadata({decode_item(item), metadata}, revision)}
    end
  end

  @doc false
  def get_revision(item_type, item_id, revision, options) do
      repo = extract_repo(options)
      item_type = to_string item_type
      revisions_table = extract_table_name(options)
      item_id_type = item_id_type(options)

      case repo.all(
            from r in revisions_table,
            where: r.item_type == ^item_type and r.item_id == type(^item_id, ^item_id_type) and r.revision == ^revision,
            limit: 1,
            select: {r.revision, {r.encoded_item, r.metadata}}
          ) do
      [] -> :error
      [{revision, {item, metadata}}] -> {:ok, put_revision_in_metadata({decode_item(item), metadata}, revision)}
    end
  end

  @doc false
  def delete_all_revisions_of(item_type, item_id, options) do
    repo = extract_repo(options)
    item_type = to_string item_type
    revisions_table = extract_table_name(options)
    item_id_type = item_id_type(options)

    repo.delete_all(from r in revisions_table, where: r.item_type == ^item_type and r.item_id == type(^item_id, ^item_id_type))
    :ok
  end

  defp extract_repo(options) do
    options[:repo] || Application.fetch_env!(:revisionair_ecto, :repo)
  end

  defp put_revision_in_metadata({item, metadata}, revision) do
    {item, Map.put(metadata, :revision, revision)}
  end

  defp next_revision(item_type, item_id, repo, revisions_table, item_id_type) do
    case repo.all(from r in revisions_table, where: r.item_type == ^item_type and r.item_id == type(^item_id, ^item_id_type), select: r.revision, limit: 1, order_by: [desc: :revision]) do
      [] -> 0
      [num] -> num + 1
    end
  end

  defp encode_item_id(item_id, Ecto.UUID) do
    {:ok, dumped_item_id} = Ecto.UUID.dump(item_id)
    dumped_item_id
  end

  defp encode_item_id(item_id, :integer) do
    item_id
  end

  defp encode_item(item) do
    :erlang.term_to_binary(item)
  end

  defp decode_item(item_binary) do
    :erlang.binary_to_term(item_binary)
  end

  defp extract_table_name(options) do
    options[:revisions_table] || Application.get_env(:revisionair_ecto, :revisions_table, "revisions")
  end

  defp item_id_type(options) do
    if options[:item_id_type] do
      map_item_id_type_option_to_item_id_type(options[:item_id_type])
    else
      map_item_id_type_option_to_item_id_type(Application.get_env(:revisionair_ecto, :item_id_type, :integer))
    end
  end

  defp map_item_id_type_option_to_item_id_type(:uuid), do: Ecto.UUID
  defp map_item_id_type_option_to_item_id_type(:integer), do: :integer
  defp map_item_id_type_option_to_item_id_type(_), do: :integer
end

# To test normal, numerical IDs.
defmodule Post do
  use Ecto.Schema

  schema "posts" do
    field :title, :string
    field :content, :string
  end
end

# To test working with UUIDs.
defmodule UUIDPost do
  use Ecto.Schema

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "uuid_posts" do
    field :title, :string
    field :content, :string
  end
end

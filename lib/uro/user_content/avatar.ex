defmodule Uro.UserContent.Avatar do
  import Ecto.Changeset
  use Uro.UserContent.UserContent

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  @derive {Phoenix.Param, key: :id}
  schema "avatars" do
    user_content_fields()

    timestamps()
  end

  @doc false
  def changeset(avatar, attrs) do
    IO.puts "Debug changeset"
    IO.inspect avatar
    IO.inspect attrs
    IO.puts "End debug"
    user_content_changeset(avatar, attrs)
  end

  @doc false
  def upload_changeset(avatar, attrs) do
    IO.puts "Debug upload changeset"
    IO.inspect avatar
    IO.inspect attrs
    IO.puts "End debug"
    user_content_upload_changeset(avatar, attrs)
  end
end

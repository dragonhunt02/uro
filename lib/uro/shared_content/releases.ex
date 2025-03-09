defmodule Uro.SharedContent.Releases do
  import Ecto.Changeset
  use Uro.SharedContent.SharedContent

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  @derive {Phoenix.Param, key: :id}
  schema "releases" do
    shared_content_fields()

    timestamps()
  end

  @doc false
  def changeset(avatar, attrs) do
    shared_content_changeset(avatar, attrs)
  end

  @doc false
  def upload_changeset(avatar, attrs) do
    shared_content_upload_changeset(avatar, attrs)
  end
end

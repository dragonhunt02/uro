defmodule Uro.SharedContent.SharedContent do
  alias Ecto.Changeset

  @doc false
  defmacro __using__(_config) do
    quote do
      use Ecto.Schema
      use Waffle.Ecto.Schema

      @derive {Jason.Encoder,
               only: [
                 :description,
                 :name,
                 :shared_content_data,
                 :uploader_id,
                 :is_public
               ]}
      import unquote(__MODULE__), only: [shared_content_fields: 0]

      @spec shared_content_changeset(Ecto.Schema.t() | Changeset.t(), map()) :: Changeset.t()
      def shared_content_changeset(changeset, attrs) do
        changeset
        |> cast(attrs, [:name, :description, :file_path, :file_size, :file_type,
          :checksum, :upload_date, :uploader_id, :is_public,
          :version, :tags, :permissions])
        |> foreign_key_constraint(:uploader_id)
      end

      def shared_content_upload_changeset(changeset, attrs) do
        changeset
        |> cast_attachments(attrs, [:shared_content_data])
        |> validate_required([:name, :uploader_id, :shared_content_data])
        |> populate_file_data(attrs)
      end

      defp populate_file_data(changeset, attrs) do
        case Map.get(attrs, "shared_content_data") do
          %Plug.Upload{path: path} ->
            file_info = File.stat!(path)

            changeset
            |> put_change(:file_path, path)
            |> put_change(:file_size, file_info.size)
            # |> put_change(:file_type, MIME.from_path(path))
            |> put_change(:upload_date, DateTime.utc_now(:second))
            |> put_change(:checksum, generate_checksum(path))
          _ ->
            changeset
        end
      end

      defp generate_checksum(file_path) do
        :crypto.hash(:sha256, File.read!(file_path))
        |> Base.encode16(case: :lower)
      end

    end
  end

  @doc false
  defmacro shared_content_fields() do
    quote do
      field :name, :string
      field :description, :string
      field :file_path, :string
      field :file_size, :integer
      field :file_type, :string
      field :checksum, :string
      field :upload_date, :utc_datetime
      field :is_public, :boolean
      field :version, :string
      field :tags, {:array, :string}
      field :permissions, :map
      field :shared_content_data, Uro.Uploaders.SharedContentData.Type
      belongs_to :uploader, Uro.Accounts.User, foreign_key: :uploader_id, type: :binary_id
    end
  end
end

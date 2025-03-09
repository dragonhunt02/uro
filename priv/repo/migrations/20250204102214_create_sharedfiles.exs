defmodule Uro.Repo.Migrations.CreateSharedFiles do
  use Ecto.Migration

  def change do
    create table(:shared_files) do
      add :id, :uuid, primary_key: true
      add :name, :string
      add :description, :string
      add :shared_content_data, :string
      add :file_path, :string
      add :file_size, :integer
      add :file_type, :string
      add :checksum, :string
      add :upload_date, :utc_datetime
      add :uploader_id, references(:users, type: :uuid)
      add :is_public, :boolean
      add :version, :string
      add :tags, {:array, :string}
      add :permissions, :map
      add :is_public, :boolean, default: false, null: false

      timestamps()
    end
  end
end

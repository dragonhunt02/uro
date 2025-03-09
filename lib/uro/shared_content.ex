defmodule Uro.SharedContent do
  @moduledoc """
  The Content context.
  """

  import Ecto.Query, warn: false
  alias Uro.Repo

  alias Uro.SharedContent.SharedFile
  alias Uro.UserContent.Avatar

  @doc """
  Returns the list of all storage files.

  ## Examples

      iex> list_shared_files()
      [%SharedFile{}, ...]

  """
  def list_shared_files do
    SharedFile
    |> Repo.all()
    |> Repo.preload([:uploader])
  end

  @doc """
  Returns the list of avatars with pagination
  """
  def list_avatars_paginated(params) do
    Avatar
    |> Repo.paginate(params)
  end

  @doc """
  Returns the list of avatars marked as public
  """
  def list_public_shared_files() do
    SharedFile
    |> where(is_public: true)
    |> Repo.all()
    |> Repo.preload([:uploader])
  end

  @doc """
  Returns the list of avatars marked as public with pagination
  """
  def list_public_avatars_paginated(params) do
    Avatar
    |> where(is_public: true)
    |> Repo.paginate(params)
  end

  @doc """
  Returns the list of avatars uploaded by a user.

  ## Examples

      iex> list_avatars_uploaded_by(user)
      [%Avatar{}, ...]

  """
  def list_avatars_uploaded_by(user) do
    Avatar
    |> where(uploader_id: ^user.id)
    |> Repo.all()
    |> Repo.preload([:uploader])
  end

  @doc """
  Returns the list of avatars uploaded by a user with pagination.
  """
  def list_avatars_uploaded_by_with_pagination(params, user) do
    Avatar
    |> where(uploader_id: ^user.id)
    |> Repo.paginate(params)
  end

  @doc """
  Gets a single avatar.

  Raises `Ecto.NoResultsError` if the Avatar does not exist.

  ## Examples

      iex> get_avatar!(123)
      %Avatar{}

      iex> get_avatar!(456)
      ** (Ecto.NoResultsError)

  """
  def get_avatar!(id) do
    SharedFile
    |> Repo.get!(id)
    |> Repo.preload([:uploader])
  end

  @doc """
  Gets a single public avatar.

  Raises `Ecto.NoResultsError` if the Avatar does not exist or is inaccessible.

  """
  def get_public_avatar!(id) do
    SharedFile
    |> where(is_public: true)
    |> Repo.get!(id)
    |> Repo.preload([:uploader])
  end

  @doc """
  Gets a single avatar uploaded by a specified user.

  Raises `Ecto.NoResultsError` if the Avatar does not exist or was not uploaded by this user.
  """
  def get_avatar_uploaded_by_user!(id, user) do
    Avatar
    |> where(uploader_id: ^user.id)
    |> Repo.get!(id)
    |> Repo.preload([:uploader])
  end

  @doc """
  Creates a storage file.

  ## Examples

      iex> create_shared_file(%{field: value})
      {:ok, %SharedFile{}}

      iex> create_shared_file(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_shared_file(attrs \\ %{}) do
    shared_content = %SharedFile{}

    Ecto.Multi.new()
    |> Ecto.Multi.insert(:shared_content, SharedFile.changeset(shared_content, attrs))
    |> Ecto.Multi.update(
      :shared_content_with_upload,
      &SharedFile.upload_changeset(&1.shared_content, attrs)
    )
    |> Repo.transaction()
    |> case do
      {:ok, %{shared_content_with_upload: shared_content_with_upload}} ->
        {:ok, shared_content_with_upload}

      {:error, _, reason, _} ->
        {:error, reason}
    end
  end

  @doc """
  Updates a avatar.

  ## Examples

      iex> update_avatar(avatar, %{field: new_value})
      {:ok, %Avatar{}}

      iex> update_avatar(avatar, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_avatar(%Avatar{} = avatar, attrs) do
    avatar
    |> Avatar.changeset(attrs)
    |> Avatar.upload_changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a avatar.

  ## Examples

      iex> delete_avatar(avatar)
      {:ok, %Avatar{}}

      iex> delete_avatar(avatar)
      {:error, %Ecto.Changeset{}}

  """
  def delete_avatar(%Avatar{} = avatar) do
    Repo.delete(avatar)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking avatar changes.

  ## Examples

      iex> change_avatar(avatar)
      %Ecto.Changeset{source: %Avatar{}}

  """
  def change_avatar(%Avatar{} = avatar) do
    Avatar.changeset(avatar, %{})
  end



end

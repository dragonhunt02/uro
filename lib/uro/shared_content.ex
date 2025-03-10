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
  Gets a single public file.

  Raises `Ecto.NoResultsError` if the SharedFile does not exist or is inaccessible.

  """
  def get_public_shared_file!(id) do
    SharedFile
    |> where(is_public: true)
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
  Updates a file.

  ## Examples

      iex> update_shared_file(shared_file, %{field: new_value})
      {:ok, %Avatar{}}

      iex> update_shared_file(shared_file, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_shared_file(%SharedFile{} = shared_file, attrs) do
    shared_file
    |> SharedFile.changeset(attrs)
    |> SharedFile.upload_changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a file.

  ## Examples

      iex> delete_shared_file(shared_file)
      {:ok, %SharedFile{}}

      iex> delete_shared_file(shared_file)
      {:error, %Ecto.Changeset{}}

  """
  def delete_shared_file(%SharedFile{} = shared_file) do
    Repo.delete(shared_file)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking file changes.

  ## Examples

      iex> change_shared_file(shared_file)
      %Ecto.Changeset{source: %SharedFile{}}

  """
  def change_shared_file(%SharedFile{} = shared_file) do
    SharedFile.changeset(avatar, %{})
  end



end

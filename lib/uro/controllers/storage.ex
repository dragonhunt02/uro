defmodule Uro.StorageController do
  use Uro, :controller

  alias OpenApiSpex.Schema
  alias Uro.UserContent
  alias Uro.SharedContent

  action_fallback Uro.FallbackController

  tags(["storage"])

  operation(:index,
    operation_id: "listSharedFiles",
    summary: "List all storage files",
    responses: [
      ok: {
        "",
        "application/json",
        %Schema{}
      }
    ]
  )

  def index(conn, _params) do
    file_list = SharedContent.list_public_shared_files()

    conn
    |> put_status(200)
    |> json(%{
      data: %{
        files:
          Uro.Helpers.SharedContentHelper.get_api_shared_content_list(file_list, %{
            merge_uploader_id: true
          })
      }
    })
  end

  operation(:show,
    operation_id: "getAvatar",
    summary: "Get Avatar",
    responses: [
      ok: {
        "",
        "application/json",
        %Schema{}
      }
    ]
  )

  def show(conn, %{"id" => id}) do
    id
    |> UserContent.get_avatar!()
    |> case do
      %Uro.UserContent.Avatar{} = avatar ->
        conn
        |> put_status(200)
        |> json(%{
          data: %{
            avatar:
              Uro.Helpers.UserContentHelper.get_api_user_content(
                avatar,
                %{merge_uploader_id: true, merge_is_public: true}
              )
          }
        })

      _ ->
        put_status(
          conn,
          400
        )
    end
  end

  operation(:create,
    operation_id: "createFile",
    summary: "Upload file to server storage",
    responses: [
      ok: {
        "",
        "application/json",
        %Schema{}
      }
    ]
  )

  def create(conn, %{"storage" => storage_params}) do
    case SharedContent.create_shared_file(
      Uro.Helpers.SharedContentHelper.get_correct_shared_content_params(conn, storage_params, "shared_content_data")) do
      {:ok, stored_file} ->
        conn
        |> put_status(200)
        |> json(%{
          data: %{
            id: to_string(stored_file.id),
            file:
              Uro.Helpers.SharedContentHelper.get_api_shared_content(
                stored_file,
                %{merge_uploader_id: true}
              )
          }
        })

      {:error, %Ecto.Changeset{changes: _changes, errors: _errors} = changeset} ->
        {:error, changeset}
    end
  end

  operation(:update,
    operation_id: "updateAvatar",
    summary: "Update Avatar",
    responses: [
      ok: {
        "",
        "application/json",
        %Schema{}
      }
    ]
  )

  def update(conn, %{"id" => id, "avatar" => avatar_params}) do
    user = Uro.Helpers.Auth.get_current_user(conn)
    avatar = UserContent.get_avatar_uploaded_by_user!(id, user)

    case UserContent.update_avatar(avatar, avatar_params) do
      {:ok, avatar} ->
        conn
        |> put_status(200)
        |> json(%{
          data: %{
            id: to_string(avatar.id),
            avatar:
              Uro.Helpers.UserContentHelper.get_api_user_content(
                avatar,
                %{merge_uploader_id: true}
              )
          }
        })

      {:error, %Ecto.Changeset{changes: _changes, errors: _errors} = changeset} ->
        {:error, changeset}
    end
  end

  operation(:delete,
    operation_id: "deleteAvatar",
    summary: "Delete Avatar",
    responses: [
      ok: {
        "",
        "application/json",
        %Schema{}
      }
    ]
  )

  def delete(conn, %{"id" => id}) do
    user = Uro.Helpers.Auth.get_current_user(conn)

    case UserContent.get_avatar_uploaded_by_user!(id, user) do
      %Uro.UserContent.Avatar{} = avatar ->
        case UserContent.delete_avatar(avatar) do
          {:ok, _avatar} ->
            conn
            |> put_status(200)

          {:error, %Ecto.Changeset{}} ->
            conn
            |> put_status(500)
        end
      _ ->
        conn
        |> put_status(200)
    end
  end
end

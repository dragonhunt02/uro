defmodule Uro.AvatarController do
  use Uro, :controller

  alias OpenApiSpex.Schema
  alias Uro.UserContent

  tags(["avatars"])

  operation(:index,
    operation_id: "listAvatars",
    summary: "List Avatars",
    responses: [
      ok: {
        "",
        "application/json",
        %Schema{}
      }
    ]
  )

  def index(conn, _params) do
    avatars = UserContent.list_public_avatars()

    conn
    |> put_status(200)
    |> json(%{
      data: %{
        avatars:
          Uro.Helpers.UserContentHelper.get_api_user_content_list(avatars, %{
            merge_uploader_id: true
          })
      }
    })
  end

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
end

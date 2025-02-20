# Script for populating the database. You can run it as:
#
#     mix run priv/repo/test_user_content.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Uro.Repo.insert!(%Uro.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias Uro.UserContent
alias Uro.Repo

current_time = DateTime.utc_now()
def get_uploader_id_by_username(username) do
  user = Repo.get_by(Uro.Accounts.User, username: username)
  user.id
end

uploader = get_uploader_id_by_username("adminuser")

UserContent.create_avatar(%{
      name: "TestScene1",
      description: "First test scene",
      user_content_data: "test_scene1.tscn",
      uploader_id: uploader,
      user_content_preview: "teststring.jpg",
      is_public: true
})


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

#current_time = DateTime.utc_now()
#def get_uploader_id_by_username(username) do

# Copy test assets
case File.cp_r("priv/repo/test_content", "uploads") do
  {:ok, _} -> IO.puts("Test Files copied successfully.")
  {:error, reason} -> IO.puts("Failed to copy files: #{reason}")
end

# Create upload database entries
user = Repo.get_by(Uro.Accounts.User, username: "adminuser")
IO.inspect user
uploader = user.id
#end

# uploader = get_uploader_id_by_username("adminuser")

error = UserContent.create_avatar(%{
      name: "TestAvatar1",
      description: "First test avatar",
      user_content_data: "uploads/test_avatar1.scn",
      uploader_id: uploader,
      user_content_preview: "uploads/teststring.jpg",
      is_public: true
})

IO.inspect error

error = UserContent.create_map(%{
      name: "TestScene1",
      description: "First test scene",
      user_content_data: "uploads/test_scene1.scn",
      uploader_id: uploader,
      user_content_preview: "uploads/teststring.jpg",
      is_public: true
})

IO.inspect error

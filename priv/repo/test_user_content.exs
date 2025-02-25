# Script for populating the database. You can run it as:
#
#     mix run priv/repo/test_user_content.exs
#
# Script must be run from repository root

alias Uro.UserContent
alias Uro.Repo

#current_time = DateTime.utc_now()
#def get_uploader_id_by_username(username) do

# Copy test assets
case File.cp_r("priv/repo/test_content/", "uploads/") do
  {:ok, _} -> IO.puts("Test Files copied successfully.")
  {:error, reason} -> IO.puts("Failed to copy files: #{reason}")
end

# Create upload database entries
user = Repo.get_by(Uro.Accounts.User, username: "adminuser")
IO.inspect user
uploader = user.id
#end

# uploader = get_uploader_id_by_username("adminuser")

process_file = fn (path, content_type) -> 
  file = %Plug.Upload{
    path: path,
    filename: Path.basename(path),
    content_type: content_type
  }
  file
end


error = UserContent.create_avatar(%{
      name: "TestAvatar1",
      description: "First test avatar",
      user_content_data: process_file.("uploads/test_avatar1.scn", "application/octet-stream"),
      uploader_id: uploader,
      user_content_preview: process_file.("uploads/test_image.jpg", "image/jpeg"),
      is_public: true
})

IO.inspect error

error = UserContent.create_map(%{
      name: "TestScene1",
      description: "First test scene",
      user_content_data: process_file.("uploads/test_scene1.scn", "application/octet-stream"),
      uploader_id: uploader,
      user_content_preview: process_file.("uploads/test_image.jpg", "image/jpeg"),
      is_public: true
})

IO.inspect error

error = UserContent.create_map(%{
      name: "TestScene2",
      description: "Second test scene",
      user_content_data: process_file.("uploads/test_scene2.scn", "application/octet-stream"),
      uploader_id: uploader,
      user_content_preview: process_file.("uploads/test_image.jpg", "image/jpeg"),
      is_public: true
})

IO.inspect error

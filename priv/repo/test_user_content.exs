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

uploader_id = get_uploader_id_by_username("adminuser")

UserContent.create_avatar(%{
      name: "TestScene1",
      description: "First test scene",
      user_content_data: "test_scene1.tscn",
      uploader_id: references(:users, type: :uuid),
      user_content_preview: string,
      is_public: true
})


  # Upsert admin user and their privileges
  admin_user =
    User
    |> Repo.get_by(email: "admin@example.com")
    |> case do
      nil ->
        %User{}
        |> User.admin_changeset(%{
          email: "admin@example.com",
          username: "adminuser",
          display_name: "Admin User",
          email_notifications: true,
          password: "adminpassword",
          password_confirmation: "adminpassword",
          email_confirmed_at: current_time
        })
        |> Repo.insert!()
      user ->
        user
        |> User.admin_changeset(%{email_confirmed_at: current_time})
        |> Repo.update!()
    end

  # Ensure admin user privileges exist with additional permissions
  admin_privileges_params = %{
    user_id: admin_user.id,
    is_admin: true,
    can_upload_avatars: true,
    can_upload_maps: true,
    can_upload_props: true
  }
  UserPrivilegeRuleset
  |> Repo.get_by(user_id: admin_user.id)
  |> case do
    nil ->
      %UserPrivilegeRuleset{}
      |> UserPrivilegeRuleset.admin_changeset(admin_privileges_params)
      |> Repo.insert!()
  end
end)

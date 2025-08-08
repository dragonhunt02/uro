defmodule Uro.Oauth.Vroid do 
  use Assent.Strategy.OAuth2.Base

  @impl true
  def default_config(_config) do
     config = Application.get_env(:uro, :pow_assent)[:providers][:vroid]
    [
      base_url: "https://hub.vroid.com",
      authorize_url: "/oauth/authorize",
      token_url: "/oauth/token",
      user_url: "/api/account",

      authorization_params: [response_type: "code", scope: "default"],  #, client_id: config[:client_id], client_secret: config[:client_secret]],
      token_params: [grant_type: "authorization_code"],
token_request_method: :get,

      #headers: [{"X-Api-Version", "11"}],
      #auth_headers: [{"X-Api-Version", "10"}],
      base_headers: [{"X-Api-Version", "11"}],

      auth_method: :client_secret_post
    ]
  end

  @impl true
  def normalize(_config, %{
        "data" => %{
          "user_detail" => %{
            "user" => user
          }
        }
      }) do
    avatar = get_in(user, ["icon", "sq170", "url"])
    IO.inspect(avatar)

    {:ok,
     %{
       "sub"     => user["id"],
       "name"    => user["name"],
       "picture" => avatar,
       "email" => "#{user["id"]}@vroid.vsekai.local" # placeholder
    }}
  end
end

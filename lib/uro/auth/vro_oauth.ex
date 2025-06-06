defmodule Uro.Oauth.Vroid do 
  use Assent.Strategy.OAuth2.Base

  @impl true
  def default_config(_config) do
    [
      base_url: "https://hub.vroid.com",
      authorize_url: "/oauth/authorize",
      token_url: "/oauth/token",
      user_url: "/api/account",

      authorization_params: [response_type: "code", scope: "default"],
      token_params: [grant_type: "authorization_code"],

      headers: [{"X-Api-Version", "11"}],

      auth_method: :client_secret_basic
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

    {:ok,
     %{
       "sub"     => user["id"],
       "name"    => user["name"],
       "picture" => avatar
    }}
  end
end

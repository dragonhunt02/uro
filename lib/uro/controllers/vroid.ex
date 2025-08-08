defmodule Uro.Oauth.AuthorizationController do
  use Uro, :controller

  require Logger
  require IEx
  alias Plug.Conn
  alias PowAssent.Plug

  action_fallback Uro.FallbackController

  tags(["app_oauth"])

  @spec new(Conn.t(), map()) :: Conn.t()
  def new(conn, %{"provider" => provider}) do
    IO.puts("testing new #{provider}")
    prov_cfg=get_provider_cfg(provider)
    IO.inspect(prov_cfg)

    conn
    |> Plug.authorize_url(provider, redirect_uri(provider))
    |> case do
      {:ok, url, conn} ->
        json(conn, %{data: %{url: url, session_params: conn.private[:pow_assent_session_params]}})

      {:error, _error, conn} ->
        conn
        |> put_status(500)
        |> json(%{error: %{status: 500, message: "An unexpected error occurred"}})
    end
  end

  defp redirect_uri(provider) do
    IO.inspect(provider, label: "get_provider_cfg/1 called with")

    cfg = get_provider_cfg(provider)
    uri = Keyword.get(cfg, :redirect_uri, "")
  end

  # On successful oauth, use localhost redirect to send back tokens to client
  defp client_redirect_uri(provider) do
    IO.inspect(provider, label: "get_provider_cfg/1 called with")

    cfg = get_provider_cfg(provider)
    url = case Keyword.fetch(cfg, :client_redirect_port) do
      {:ok, port} -> "http://localhost:#{port}/"
      :error -> "http://0.0.0.0/" #TODO: replace with error page
    end
    IO.inspect(url)
    url
  end

  @spec callback(Conn.t(), map()) :: Conn.t()
  def callback(conn, %{"provider" => provider, "code" => code, "state" => state} = params) do
    IO.inspect(conn)
    IO.inspect(params)
    session_params = %{code: code, state: state}
    IO.puts("Debug callback")
    IO.inspect(params)
    IO.inspect(session_params)

    conn
    #|> Conn.put_private(:pow_assent_callback_params, session_params)
    |> Conn.put_private(:pow_assent_session_params, session_params)
    |> Plug.callback_upsert(provider, params, redirect_uri(provider))
    |> case do
      {:ok, conn} ->
        IO.inspect(conn.private)
        api_tokens = conn.private.pow_assent_callback_params.user_identity["token"]
        token_data = api_tokens
          |> Map.take(["access_token", "refresh_token", "expires_in"])
        params = Map.put(token_data, "provider", provider)
        redirect_uri = client_redirect_uri(provider) <> "?" <> URI.encode_query(params)
        html = make_client_redirect_page(provider, redirect_uri, 5)
        conn
        |> put_resp_content_type("text/html")
        |> send_resp(200, html)
        #json(conn, %{data: token_data })

      {:error, conn} ->
        html = make_error_page(provider)
        conn
        |> put_resp_content_type("text/html")
        |> send_resp(500, html)
        #|> put_status(500)
        #|> json(%{error: %{status: 500, message: "An unexpected error occurred"}})
    end
  end

def make_client_redirect_page(provider, redirect_uri, wait_time) do
  provider_name = String.capitalize(provider)
  html = ~s"""
  <!DOCTYPE html>
  <html>
    <head>
      <meta charset="utf-8">
      <meta http-equiv="refresh"
            content="#{wait_time};url=#{redirect_uri}">
      <title>#{provider_name} OAuth</title>
    </head>
    <body>
      <h1>#{provider_name} OAuth</h1>
      <p>#{provider_name} login was successful. Sending data to V-Sekai client in #{wait_time} seconds. If not, <a href="#{redirect_uri}">click here</a>.</p>
    </body>
  </html>
  """
end

def make_error_page(provider) do
  provider_name = String.capitalize(provider)
  html = ~s"""
  <!DOCTYPE html>
  <html>
    <head>
      <meta charset="utf-8">
      <title>#{provider_name} OAuth</title>
    </head>
    <body>
      <h1>#{provider_name} OAuth</h1>
      <p>#{provider_name} login failed. An unexpected error occurred.</p>
    </body>
  </html>
  """
end

  @doc """
  Fetches the config for the given provider name (string).
  Returns the options keyword list or `[]` if not found.
  Atom table is not modified.
  """
  @spec get_provider_cfg(String.t() | atom()) :: keyword()
  def get_provider_cfg(provider_name) when is_binary(provider_name) do
    Application.get_env(:uro, :pow_assent, [])
    |> Keyword.get(:providers, [])
    #|> IO.inspect()
    |> Enum.find_value([], fn {provider_atom, opts} ->
      name = Atom.to_string(provider_atom)

      if name == provider_name do
        #IO.puts("Matched provider: #{name}")
        opts
      end
    end)
  end

  def get_provider_cfg(provider_name) when is_atom(provider_name) do
    Application.get_env(:uro, :pow_assent, []) 
    |> Keyword.get(:providers, [])
    #|> IO.inspect()
    |> Enum.find_value([], fn {provider_atom, opts} ->

      if provider_name == provider_atom do
        IO.puts("Matched provider atom: #{provider_name}")
        opts
      end
    end)
  end

end

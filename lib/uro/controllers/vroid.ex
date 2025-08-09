defmodule Uro.Oauth.AuthorizationController do
  use Uro, :controller

  require Logger
  require IEx
  alias Plug.Conn
  alias PowAssent.Plug

  action_fallback Uro.FallbackController

  tags(["app_oauth"])

  @spec new(Conn.t(), map()) :: Conn.t()
def new(conn, %{"provider" => request_provider}) do
  IO.puts("testing new #{request_provider}")

  case get_provider_cfg(request_provider) do
    {provider_atom, cfg} when is_atom(provider_atom) and is_list(cfg) and cfg != [] ->
      provider = Atom.to_string(provider_atom)
      IO.inspect(cfg)
      IO.inspect(provider)

      conn
      |> Plug.authorize_url(provider, get_redirect_uri(cfg))
      |> case do
        {:ok, url, conn} ->
          json(conn, %{data: %{url: url, session_params: conn.private[:pow_assent_session_params]}})

        {:error, _error, conn} ->
          conn
          |> put_status(500)
          |> json(%{error: %{status: 500, message: "An unexpected error occurred"}})
      end

    _ ->
      conn
      |> put_status(500)
      |> json(%{error: %{status: 500, message: "Provider not found"}})
  end
end

  defp get_redirect_uri(config) do
    uri = Keyword.get(config, :redirect_uri, "")
  end

  # On successful oauth, use localhost redirect to send back tokens to client
  defp get_client_redirect_uri(config) do
    uri = case Keyword.fetch(config, :client_redirect_port) do
      {:ok, port} -> "http://localhost:#{port}/"
      :error -> "http://0.0.0.0/" #TODO: replace with error page
    end
    IO.inspect(uri)
    uri
  end

@spec callback(Conn.t(), map()) :: Conn.t()
def callback(conn, %{"provider" => request_provider, "code" => code, "state" => state} = params) do
  IO.puts("Debug callback for #{request_provider}")
  session_params = %{code: code, state: state}

  case get_provider_cfg(request_provider) do
    {provider_atom, cfg} when is_atom(provider_atom) and is_list(cfg) and cfg != [] ->
      provider = Atom.to_string(provider_atom)
      conn
      |> Conn.put_private(:pow_assent_session_params, session_params)
      |> Plug.callback_upsert(provider, params, get_redirect_uri(cfg))
      |> case do
        {:ok, conn} ->
          api_tokens =
            conn.private.pow_assent_callback_params.user_identity["token"]

          token_data =
            api_tokens
            |> Map.take(["access_token", "refresh_token", "expires_in"])

          client_params =
            token_data
            |> Map.put("provider", provider)

          redirect_uri = get_client_redirect_uri(cfg) <> "?" <> URI.encode_query(client_params)
          html = make_client_redirect_page(provider, redirect_uri, 5)

          conn
          |> put_resp_content_type("text/html")
          |> send_resp(200, html)

        {:error, conn} ->
          html = make_error_page(provider)

          conn
          |> put_resp_content_type("text/html")
          |> send_resp(500, html)
      end

    _ ->
      conn
      |> put_status(500)
      |> json(%{error: %{status: 500, message: "Provider not found"}})
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
    |> Enum.find({}, fn {provider_atom, opts} ->
      name = Atom.to_string(provider_atom)

      if name == provider_name do
        #IO.puts("Matched provider: #{name}")
        true
      end
    end)
  end

  def get_provider_cfg(provider_name) when is_atom(provider_name) do
    Application.get_env(:uro, :pow_assent, []) 
    |> Keyword.get(:providers, [])
    |> Enum.find({}, fn {provider_atom, opts} ->
      if provider_name == provider_atom do
        #IO.puts("Matched provider atom: #{provider_name}")
        true
      end
    end)
  end

end

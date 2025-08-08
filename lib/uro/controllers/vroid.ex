defmodule Uro.Oauth.AuthorizationController do
  use Uro, :controller

  require Logger
  require IEx
  alias Plug.Conn
  alias PowAssent.Plug
  #alias Assent.Strategy.OAuth2

  @spec new(Conn.t(), map()) :: Conn.t()
  def new(conn, %{"provider" => provider}) do
    #IEx.pry()
    conn
    |> Plug.authorize_url(provider, redirect_uri(conn))
    |> case do
      {:ok, url, conn} ->
        json(conn, %{data: %{url: url, session_params: conn.private[:pow_assent_session_params]}})

      {:error, _error, conn} ->
        conn
        |> put_status(500)
        |> json(%{error: %{status: 500, message: "An unexpected error occurred"}})
    end
  end

  defp redirect_uri(conn) do
    System.get_env("OAUTH2_VROID_REDIRECT_URI")
    #"http://localhost:7432/auth/vroid/callback"
#4000/auth/#{conn.params["provider"]}/callback"
  end


  def exchange_code(code) do
    require Logger
    config = Application.get_env(:uro, :pow_assent)[:providers][:vroid]
    IO.inspect(code)
    params = %{
      "code" => code,
      "client_id" => config[:client_id],
      "client_secret" => config[:client_secret],
      "redirect_uri" => config[:redirect_uri],
      "grant_type" => "authorization_code"
    }

    token_endpoint = "https://hub.vroid.com/oauth/token"
#config[:token_endpoint]
    provider = "vroid"
    if token_endpoint == nil do
      {:error, "Token endpoint configuration is missing"}
    else
      headers = [{"Content-Type", "application/x-www-form-urlencoded"}]
      # OAuth token requests expect URL-encoded form data.
      body = URI.encode_query(params)

      Logger.info("Exchanging code for token via #{token_endpoint} for provider #{provider}")
      IO.inspect(token_endpoint)
      IO.inspect(params, label: "parameters")
      IO.inspect(headers)
      IO.inspect(body)

      # Execute the HTTP POST.
      case HTTPoison.post(token_endpoint, body, headers, []) do
        {:ok, %HTTPoison.Response{status_code: status, body: response_body}} when status in 200..299 ->
          case Jason.decode(response_body) do
            {:ok, token_info} ->
              IO.inspect(token_info)
              {:ok, token_info}

            error ->
              Logger.error("Failed to decode JSON response: #{inspect(error)}")
              {:error, {:json_decode_error, error}}
          end

        {:ok, %HTTPoison.Response{status_code: status, body: error_body}} ->
          Logger.error("HTTP error during token exchange: status #{status}, body #{error_body}")
          {:error, {:http_error, status, error_body}}

        {:error, reason} ->
          Logger.error("HTTP request error: #{inspect(reason)}")
          {:error, reason}
      end
    end
  end

  #defmodule SessionParams do
  #  @enforce_keys [:code, :state]
  #  defstruct [:code, :state]
  #end

  @spec callback(Conn.t(), map()) :: Conn.t()
  def callback(conn, %{"provider" => provider, "code" => code, "state" => state} = params) do
    IO.inspect(conn)
    IO.inspect(params)
    session_params = %{code: code, state: state}
    #session_params = Map.fetch!(params, "session_params")
    #params         = Map.drop(params, ["provider", "session_params"])
    IO.puts("Debug callback")
    IO.inspect(params)
    IO.inspect(session_params)
    #cfg=Uro.Oauth.Vroid.config
    #assres=Uro.Oauth.Vroid.authorize_url(conn)
    #IO.inspect(assres)

    conn
    #|> Conn.put_private(:pow_assent_callback_params, session_params)
    |> Conn.put_private(:pow_assent_session_params, session_params)
    |> Plug.callback_upsert(provider, params, redirect_uri(conn))
    |> case do
      {:ok, conn} ->
        IO.inspect(conn.private)
        #IO.inspect(conn.private.pow_assent_session_params)
        #IO.inspect(conn.private.pow_assent_callback_params)
        api_tokens = conn.private.pow_assent_callback_params.user_identity["token"]
        token_data = api_tokens
          |> Map.take(["access_token", "refresh_token", "expires_in"])
        redirect_uri = "http://localhost:8432/" <> URI.encode_query(token_data)
        html = make_client_redirect_page(redirect_uri, 5)
        conn
        |> put_resp_content_type("text/html")
        |> send_resp(200, html)
        #json(conn, %{data: token_data })

      {:error, conn} ->
        conn
        |> put_status(500)
        |> json(%{error: %{status: 500, message: "An unexpected error occurred"}})
    end
  end

def make_client_redirect_page(redirect_uri, wait_time) do
  html = ~s"""
  <!DOCTYPE html>
  <html>
    <head>
      <meta charset="utf-8">
      <meta http-equiv="refresh"
            content="#{wait_time};url=#{redirect_uri}">
      <title>Vroid OAuth</title>
    </head>
    <body>
      <h1>Vroid OAuth</h1>
      <p>Vroid login was successful. Sending data to V-Sekai client in #{wait_time} seconds. If not, <a href="#{redirect_uri}">click here</a>.</p>
    </body>
  </html>
  """
end


  @spec callback1(Conn.t(), map()) :: Conn.t()
  def callback1(conn, %{"provider" => provider} = params) do
    session_params = Map.fetch!(params, "session_params")
    code = Map.get(params, "code")
    params         = Map.drop(params, ["provider", "session_params"])   #, "code"])
    #IEx.pry()
    IO.inspect(params)
    accessor = nil
    access_tokenn = nil
    accessor = case exchange_code(code) do
      {:ok, token_info} ->
        accessor = token_info
        IO.puts("all ok")
        token_info
      _ ->
        IO.puts("Bad error"); nil
    end
    IO.inspect(accessor)
    access_tokenn = Map.get(accessor, "access_token")
    session_params = Map.merge(session_params, accessor)
    IO.inspect(session_params)
    parameters = %{"access_token" => access_tokenn}
    conn
    |> Conn.put_private(:pow_assent_session_params, session_params)
    |> IO.inspect()
    #|> Plug.callback_upsert(provider, params, redirect_uri(conn))
    {:ok, conn} |> case do
      {:ok, conn} ->
        #json(conn, %{data: %{access_token: conn.private.access_token, refresh_token: conn.private.refresh_token}})
        json(conn, %{data: session_params})

      {:error, conn} ->

        error_message = conn.private[:pow_assent_callback_error] || "An unexpected error occurred"

        Logger.error(fn ->
          "Callback error for provider #{provider}: #{error_message}. " <>
          "HTTP #{conn.method} #{conn.request_path}"
        end)

        conn
        |> put_status(500)
        |> json(%{error: %{status: 500, message: "An unexpected error occurred"}})
    end
  end
end

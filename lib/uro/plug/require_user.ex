defmodule Uro.Plug.RequireUser do
  import Plug.Conn

  @doc false
  def init(options), do: options

  @doc false
  @spec call(Conn.t(), atom()) :: Conn.t()
  def call(conn, handler) do
    conn
    |> Uro.Helpers.User.is_session_user?()
    |> maybe_halt(conn, handler)
  end

  @doc false
  defp maybe_halt(true, conn, _handler), do: conn

  @doc false
  defp maybe_halt(false, conn, _handler) do
    conn
    |> put_status(403)
    |> send_resp(403, "Unauthorized 403")
    |> halt()
  end
end

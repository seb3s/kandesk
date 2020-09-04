defmodule KandeskWeb.AssignUser do
  import Plug.Conn
  alias Kandesk.Schema.User
  alias Kandesk.Repo

  def init(options), do: options

  def call(conn, params) do
    case Pow.Plug.current_user(conn) do
      %User{} = user ->
        conn |> put_session("user_id", user.id)

      _ ->
        conn
    end
  end
end

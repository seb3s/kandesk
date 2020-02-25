defmodule KandeskWeb.PageController do
  use KandeskWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end

defmodule KandeskWeb.Router do
  use KandeskWeb, :router
  use Pow.Phoenix.Router
  use Pow.Extension.Phoenix.Router,
    extensions: [PowResetPassword, PowPersistentSession]

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :liveview do
    plug :put_root_layout, {KandeskWeb.LayoutView, "live.html"}
  end

  pipeline :protected do
    plug Pow.Plug.RequireAuthenticated,
      error_handler: Pow.Phoenix.PlugErrorHandler
    plug KandeskWeb.AssignUser
  end

  scope "/" do
    pipe_through :browser

    pow_session_routes()
    pow_extension_routes()
  end

  scope "/", KandeskWeb do
    pipe_through [:browser, :liveview, :protected]

    live "/", IndexLive, session: %{"page" => "dashboard"}
  end

  # Other scopes may use custom stacks.
  # scope "/api", KandeskWeb do
  #   pipe_through :api
  # end
end

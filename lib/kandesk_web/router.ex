defmodule KandeskWeb.Router do
  use KandeskWeb, :router
  use Pow.Phoenix.Router

  use Pow.Extension.Phoenix.Router,
    extensions: [PowResetPassword, PowPersistentSession]

  # Force the compiler to process this module now
  require KandeskWeb.Cldr

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {KandeskWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug Cldr.Plug.SetLocale, apps: [:cldr, :gettext], cldr: KandeskWeb.Cldr
    plug Cldr.Plug.AcceptLanguage, cldr_backend: KandeskWeb.Cldr
  end

  pipeline :api do
    plug :accepts, ["json"]
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
    pipe_through [:browser, :protected]

    live "/", IndexLive, session: %{"page" => "dashboard"}
  end

  # Other scopes may use custom stacks.
  # scope "/api", KandeskWeb do
  #   pipe_through :api
  # end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through [:browser, :protected]
      live_dashboard "/dashboard", metrics: KandeskWeb.Telemetry
    end
  end
end

defmodule BeaconBallWeb.Router do
  use BeaconBallWeb, :router

  for p <- [:browser_public, :browser_protected, :admin_only, :admin_or_self_only] do
    pipeline :"#{p}" do
      plug :accepts, ["html"]
      plug :fetch_session
      plug :fetch_live_flash
      plug :put_root_layout, {BeaconBallWeb.LayoutView, :root}
      plug :protect_from_forgery
      plug :put_secure_browser_headers
      plug BeaconBallWeb.Plugs.Authentication

      if p != :browser_public do
        plug BeaconBallWeb.Plugs.AuthOrRedirectToLogin
      end

      case p do
        :admin_only ->
          plug BeaconBallWeb.Plugs.AdminOnly

        :admin_or_self_only ->
          plug BeaconBallWeb.Plugs.AdminOrSelfOnly

        _ ->
          nil
      end
    end
  end

  scope "/login", BeaconBallWeb do
    pipe_through :browser_public

    live "/", LoginLive.Index, :index
  end

  scope "/players", BeaconBallWeb do
    pipe_through :admin_only
    live "/new", PlayerLive.Index, :new
  end

  scope "/players", BeaconBallWeb do
    pipe_through :admin_or_self_only

    live "/:id/edit", PlayerLive.Index, :edit
    live "/:id/show/edit", PlayerLive.Show, :edit
  end

  scope "/runs", BeaconBallWeb do
    pipe_through :admin_only

    live "/new", RunLive.Index, :new
    live "/:id/edit", RunLive.Index, :edit
    live "/:id/show/edit", RunLive.Show, :edit
  end

  scope "/", BeaconBallWeb do
    pipe_through :browser_protected

    get "/", PageController, :index

    live "/players", PlayerLive.Index, :index
    live "/players/:id", PlayerLive.Show, :show

    live "/runs", RunLive.Index, :index
    live "/runs/:id", RunLive.Show, :show
  end

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
      pipe_through :browser_public

      live_dashboard "/dashboard", metrics: BeaconBallWeb.Telemetry
    end
  end
end

defmodule BeaconBallWeb.Router do
  use BeaconBallWeb, :router

  for p <- [:browser, :browser_protected] do
    pipeline :"#{p}" do
      plug :accepts, ["html"]
      plug :fetch_session
      plug :fetch_live_flash
      plug :put_root_layout, {BeaconBallWeb.LayoutView, :root}
      plug :protect_from_forgery
      plug :put_secure_browser_headers
      plug BeaconBallWeb.Plugs.Authentication

      if p == :browser_protected do
        plug BeaconBallWeb.Plugs.AuthOrRedirectToLogin
      end
    end
  end

  scope "/", BeaconBallWeb do
    pipe_through :browser

    live "/login", LoginLive.Index, :index
  end

  scope "/", BeaconBallWeb do
    pipe_through :browser_protected

    get "/", PageController, :index

    live "/players", PlayerLive.Index, :index
    live "/players/new", PlayerLive.Index, :new
    live "/players/:id/edit", PlayerLive.Index, :edit

    live "/players/:id", PlayerLive.Show, :show
    live "/players/:id/show/edit", PlayerLive.Show, :edit

    live "/runs", RunLive.Index, :index
    live "/runs/new", RunLive.Index, :new
    live "/runs/:id/edit", RunLive.Index, :edit

    live "/runs/:id", RunLive.Show, :show
    live "/runs/:id/show/edit", RunLive.Show, :edit
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
      pipe_through :browser

      live_dashboard "/dashboard", metrics: BeaconBallWeb.Telemetry
    end
  end
end

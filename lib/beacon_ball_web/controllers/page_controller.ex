defmodule BeaconBallWeb.PageController do
  use BeaconBallWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end

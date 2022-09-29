defmodule BeaconBallWeb.Plugs.Redirect do
  alias Plug.Conn

  def init(options) do
    options
  end

  def call(conn, to: to) do
    conn |> Phoenix.Controller.redirect(to: to) |> Conn.halt()
  end
end

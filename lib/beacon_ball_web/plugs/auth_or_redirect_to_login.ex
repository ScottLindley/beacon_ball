defmodule BeaconBallWeb.Plugs.AuthOrRedirectToLogin do
  alias Plug.Conn

  def init(options) do
    options
  end

  def call(conn, _options) do
    IO.inspect(conn.assigns)

    if conn.assigns[:current_player] == nil do
      conn |> Phoenix.Controller.redirect(to: "/login") |> Conn.halt()
    else
      conn
    end
  end
end

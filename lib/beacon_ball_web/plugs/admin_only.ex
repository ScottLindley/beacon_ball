defmodule BeaconBallWeb.Plugs.AdminOnly do
  alias Plug.Conn
  alias Phoenix.Controller
  alias BeaconBall.People.Player

  def init(options) do
    options
  end

  def call(conn, _options) do
    player = conn.assigns[:current_player]

    case Player.is_admin?(player) do
      true ->
        conn

      false ->
        conn
        |> Controller.put_view(BeaconBallWeb.ErrorView)
        |> Controller.render(:"401")
        |> Conn.halt()
    end
  end
end

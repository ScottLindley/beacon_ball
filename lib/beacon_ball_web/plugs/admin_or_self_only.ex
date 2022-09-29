defmodule BeaconBallWeb.Plugs.AdminOrSelfOnly do
  alias Plug.Conn
  alias Phoenix.Controller
  alias BeaconBall.People.Player

  def init(options) do
    options
  end

  def call(conn, _options) do
    player = conn.assigns[:current_player]
    %{"id" => player_id} = conn.params

    case Player.is_admin?(player) or player_id == "#{player.id}" do
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

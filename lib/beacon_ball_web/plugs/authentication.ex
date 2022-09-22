defmodule BeaconBallWeb.Plugs.Authentication do
  import Plug.Conn
  alias BeaconBall.People

  def init(options) do
    options
  end

  def call(conn, _options) do
    token = get_token(conn)

    player =
      case token do
        nil -> nil
        token -> token |> People.get_session_by_token() |> People.get_player_by_session()
      end

    assign(conn, :current_player, player)
  end

  defp get_token(conn) do
    with %Plug.Conn{cookies: %{"beacon_ball_token" => token}} <- fetch_cookies(conn) do
      token
    else
      _ -> nil
    end
  end
end

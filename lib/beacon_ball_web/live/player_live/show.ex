defmodule BeaconBallWeb.PlayerLive.Show do
  use BeaconBallWeb, :live_view

  alias BeaconBall.People

  @impl true
  def mount(_params, %{"current_player" => current_player} = session, socket) do
    {:ok,
     socket
     |> assign(:session, session)
     |> assign(:logged_in_player_id, current_player.id)
     |> assign(:is_admin, People.Player.is_admin?(current_player))}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:player, People.get_player!(id))}
  end

  defp page_title(:show), do: "Show Player"
  defp page_title(:edit), do: "Edit Player"
end

defmodule BeaconBallWeb.PlayerLive.Index do
  use BeaconBallWeb, :live_view

  alias BeaconBall.People
  alias BeaconBall.People.Player

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :players, list_players())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Player")
    |> assign(:player, People.get_player!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Player")
    |> assign(:player, %Player{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Players")
    |> assign(:player, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    player = People.get_player!(id)
    {:ok, _} = People.delete_player(player)

    {:noreply, assign(socket, :players, list_players())}
  end

  defp list_players do
    People.list_players()
  end
end

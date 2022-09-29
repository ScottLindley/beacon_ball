defmodule BeaconBallWeb.RunLive.Show do
  use BeaconBallWeb, :live_view

  alias BeaconBall.People.Player
  alias BeaconBall.Runs

  @impl true
  def mount(_params, %{"current_player" => current_player} = session, socket) do
    {:ok,
     socket |> assign(:session, session) |> assign(:is_admin, Player.is_admin?(current_player))}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:run, Runs.get_run!(id))}
  end

  defp page_title(:show), do: "Show Run"
  defp page_title(:edit), do: "Edit Run"
end

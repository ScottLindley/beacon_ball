defmodule BeaconBallWeb.RunLive.Index do
  use BeaconBallWeb, :live_view

  alias BeaconBall.People.Player
  alias BeaconBall.Runs

  @impl true
  def mount(_params, %{"current_player" => current_player}, socket) do
    {:ok,
     socket |> assign(:is_admin, Player.is_admin?(current_player)) |> assign(:runs, list_runs())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Run")
    |> assign(:run, Runs.get_run!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Run")
    |> assign(:run, Runs.build_default_run())
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Runs")
    |> assign(:run, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    %{is_admin: is_admin} = socket.assigns

    case is_admin do
      true ->
        run = Runs.get_run!(id)
        {:ok, _} = Runs.delete_run(run)

        {:noreply, assign(socket, :runs, list_runs())}

      false ->
        {:noreply,
         socket
         |> put_flash(:error, "You are not authorized to delete runs")}
    end
  end

  defp list_runs do
    Runs.list_runs()
  end
end

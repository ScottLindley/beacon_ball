defmodule BeaconBallWeb.LoginLive.Index do
  use BeaconBallWeb, :live_view

  @impl true
  def mount(_params, session, socket) do
    case Map.get(session, "current_player") do
      nil ->
        {:ok, socket}

      _ ->
        {:ok, socket |> push_redirect(to: "/")}
    end
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Login")
    |> assign(:validated_phone_number, nil)
  end

  @impl true
  def handle_info({:validated_phone_number, phone_number}, socket) do
    {:noreply, socket |> assign(:validated_phone_number, phone_number)}
  end
end

defmodule BeaconBallWeb.PlayerLive.FormComponent do
  use BeaconBallWeb, :live_component

  alias BeaconBall.People

  @impl true
  def update(%{player: player} = assigns, socket) do
    changeset = People.change_player(player)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"player" => player_params}, socket) do
    changeset =
      socket.assigns.player
      |> People.change_player(player_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"player" => player_params}, socket) do
    save_player(socket, socket.assigns.action, player_params)
  end

  defp save_player(socket, :edit, player_params) do
    case People.update_player(socket.assigns.player, player_params) do
      {:ok, _player} ->
        {:noreply,
         socket
         |> put_flash(:info, "Player updated successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_player(socket, :new, player_params) do
    case People.create_player(player_params) do
      {:ok, _player} ->
        {:noreply,
         socket
         |> put_flash(:info, "Player created successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
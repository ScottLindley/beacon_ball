defmodule BeaconBallWeb.RunLive.FormComponent do
  use BeaconBallWeb, :live_component

  alias BeaconBall.Runs

  @impl true
  def update(%{run: run} = assigns, socket) do
    changeset = Runs.change_run(run)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"run" => run_params}, socket) do
    changeset =
      socket.assigns.run
      |> Runs.change_run(run_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"run" => run_params}, socket) do
    save_run(socket, socket.assigns.action, run_params)
  end

  defp save_run(socket, :edit, run_params) do
    %{is_admin: is_admin} = socket.assigns

    case is_admin do
      true ->
        case Runs.update_run(socket.assigns.run, run_params) do
          {:ok, _run} ->
            {:noreply,
             socket
             |> put_flash(:info, "Run updated successfully")
             |> push_redirect(to: socket.assigns.return_to)}

          {:error, %Ecto.Changeset{} = changeset} ->
            {:noreply, assign(socket, :changeset, changeset)}
        end

      false ->
        {:noreply,
         socket
         |> put_flash(:error, "You are not authorized to edit runs")
         |> push_redirect(to: socket.assigns.return_to)}
    end
  end

  defp save_run(socket, :new, run_params) do
    %{is_admin: is_admin} = socket.assigns

    case is_admin do
      true ->
        case Runs.create_run(run_params) do
          {:ok, _run} ->
            {:noreply,
             socket
             |> put_flash(:info, "Run created successfully")
             |> push_redirect(to: socket.assigns.return_to)}

          {:error, %Ecto.Changeset{} = changeset} ->
            {:noreply, assign(socket, changeset: changeset)}
        end

      false ->
        {:noreply,
         socket
         |> put_flash(:error, "You are not authorized to create runs")
         |> push_redirect(to: socket.assigns.return_to)}
    end
  end
end

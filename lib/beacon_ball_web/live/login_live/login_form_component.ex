defmodule BeaconBallWeb.LoginLive.LoginFormComponent do
  use BeaconBallWeb, :live_component
  alias BeaconBall.People

  use Ecto.Schema
  alias Ecto.Changeset

  embedded_schema do
    field :phone_number, :string
  end

  @impl true
  def update(assigns, socket) do
    form_data = %__MODULE__{phone_number: ""}
    params = %{}
    changeset = changeset(form_data, params)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:form_data, form_data)
     |> assign(:changeset, changeset)}
  end

  def handle_event("validate", %{"form_data" => form_data}, socket) do
    changeset = changeset(socket.assigns.form_data, form_data)

    {:noreply,
     socket
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("save", %{"form_data" => form_data}, socket) do
    %{"phone_number" => phone_number} = form_data

    case People.login(phone_number) do
      {:error, message} ->
        changeset = %{changeset(socket.assigns.form_data, form_data) | action: :login}

        {:noreply,
         socket
         |> assign(
           :changeset,
           Changeset.add_error(changeset, :phone_number, message)
         )}

      {:ok, parsed_phone_number} ->
        send(self(), {:validated_phone_number, parsed_phone_number})
        {:noreply, socket}
    end
  end

  defp changeset(form_data, params) do
    form_data
    |> Changeset.cast(params, [:phone_number])
    |> Changeset.validate_required([:phone_number])
  end
end

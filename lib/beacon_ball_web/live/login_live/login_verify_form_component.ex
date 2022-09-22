defmodule BeaconBallWeb.LoginLive.LoginVerifyFormComponent do
  use BeaconBallWeb, :live_component
  alias BeaconBall.People

  use Ecto.Schema
  alias Ecto.Changeset

  embedded_schema do
    field :verification_code, :string
  end

  @impl true
  def update(assigns, socket) do
    form_data = %__MODULE__{verification_code: ""}
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
    %{"verification_code" => verification_code} = form_data
    phone_number = socket.assigns.phone_number

    case People.login_verify(phone_number, verification_code) do
      {:error, message} ->
        changeset = %{changeset(socket.assigns.form_data, form_data) | action: :login}

        {:noreply,
         socket
         |> assign(
           :changeset,
           Changeset.add_error(changeset, :verification_code, message)
         )}

      {:ok, token} ->
        {:noreply,
         socket
         |> push_event("set-cookie", %{
           key: "beacon_ball_token",
           value: token
         })
         |> push_event("redirect", %{to: "/"})}
    end
  end

  defp changeset(form_data, params) do
    form_data
    |> Changeset.cast(params, [:verification_code])
    |> Changeset.validate_required([:verification_code])
  end
end

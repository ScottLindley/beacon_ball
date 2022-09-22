defmodule BeaconBall.People.Player do
  use Ecto.Schema
  import Ecto.Changeset

  schema "players" do
    field :is_admin, :boolean, default: false
    field :name, :string
    field :phone_number, :integer

    timestamps()
  end

  @doc false
  def changeset(player, attrs) do
    player
    |> cast(attrs, [:name, :phone_number, :is_admin])
    |> validate_required([:name, :phone_number, :is_admin])
    |> validate_phone_number()
    |> unique_constraint(:phone_number)
  end

  defp validate_phone_number(changeset) do
    is_valid =
      changeset
      |> get_field(:phone_number, -1)
      |> is_valid_phone_number?()

    case is_valid do
      true ->
        changeset

      false ->
        # Note, this is not obvious, but in this context, the form input is a number, so we expect only digits.
        add_error(changeset, :phone_number, "Phone number must be in the format 1234567890")
    end
  end

  def parse_phone_number_input(phone_number) when is_binary(phone_number) do
    is_valid = is_valid_phone_number?(phone_number)

    case is_valid do
      true ->
        case Regex.replace(~r/\(|\)|\-|\s/, "#{phone_number}", "") |> Integer.parse() do
          {n, _} -> {:ok, n}
          :error -> {:error, "Unable to parse phone number"}
        end

      false ->
        # Note, this is not obvious, but in this context, the form input is a string, so we expect the numbers to be grouped by dashes.
        {:error, "Phone number must be in the format 123-456-7890"}
    end
  end

  def is_valid_phone_number?(phone_number) do
    Regex.match?(~r/[0-9]{3}-[0-9]{3}-[0-9]{4}/, "#{phone_number}") or
      Regex.match?(~r/[0-9]{10}/, "#{phone_number}")
  end
end

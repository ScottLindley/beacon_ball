defmodule BeaconBall.People do
  @moduledoc """
  The People context.
  """

  import Ecto.Query, warn: false
  alias BeaconBall.Repo

  alias BeaconBall.People.Player
  alias BeaconBall.People.Session

  @doc """
  Returns the list of players.

  ## Examples

      iex> list_players()
      [%Player{}, ...]

  """
  def list_players do
    Repo.all(Player)
  end

  @doc """
  Gets a single player.

  Raises `Ecto.NoResultsError` if the Player does not exist.

  ## Examples

      iex> get_player!(123)
      %Player{}

      iex> get_player!(456)
      ** (Ecto.NoResultsError)

  """
  def get_player!(id), do: Repo.get!(Player, id)

  def get_player_by_phone_number(phone_number) when is_integer(phone_number) do
    Repo.get_by(Player, phone_number: phone_number)
  end

  @doc """
  Creates a player.

  ## Examples

      iex> create_player(%{field: value})
      {:ok, %Player{}}

      iex> create_player(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_player(attrs \\ %{}) do
    %Player{}
    |> Player.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a player.

  ## Examples

      iex> update_player(player, %{field: new_value})
      {:ok, %Player{}}

      iex> update_player(player, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_player(%Player{} = player, attrs) do
    player
    |> Player.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a player.

  ## Examples

      iex> delete_player(player)
      {:ok, %Player{}}

      iex> delete_player(player)
      {:error, %Ecto.Changeset{}}

  """
  def delete_player(%Player{} = player) do
    Repo.delete(player)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking player changes.

  ## Examples

      iex> change_player(player)
      %Ecto.Changeset{data: %Player{}}

  """
  def change_player(%Player{} = player, attrs \\ %{}) do
    Player.changeset(player, attrs)
  end

  def login(phone_number) when is_binary(phone_number) do
    case parse_phone_number_input(phone_number) do
      {:error, message} -> {:error, message}
      {:ok, parsed_phone_number} ->
        player = get_player_by_phone_number(parsed_phone_number)
        if player === nil do
         {:error, "No player found for that phone number"}
        else
          %Session{}
          |> Session.changeset(%{
            expires_at: four_weeks_from_now(),
            # Generate radom code, use a secret to hash before persisting
            hashed_verification_code: "",
            player: player
           })
          |> Repo.insert()
           
          # Send SMS with verification code, return :ok
        end
    end
  end

  defp parse_phone_number_input(phone_number) when is_binary(phone_number) do
    case Regex.replace(~r/\(|\)|\-|\s/, phone_number, "") |> Integer.parse() do
      {n, _} -> {:ok, n}
      :error -> {:error, "Unable to parse phone number"}
    end
  end

  defp four_weeks_from_now do
    NaiveDateTime.add(NaiveDateTime.utc_now(), 1 * 60 * 60 * 24 * 28, :second)
  end
end

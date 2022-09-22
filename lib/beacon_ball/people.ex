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

  def get_player_by_session(session) do
    case session do
      nil -> nil
      session -> Repo.get(Player, session.player_id)
    end
  end

  def get_session_by_token(token) when is_binary(token) do
    session = Repo.get_by(Session, hashed_token: hash_session_token(token))

    if session do
      # Only return player if session is not expired
      case NaiveDateTime.compare(session.expires_at, NaiveDateTime.utc_now()) do
        :gt -> session
        _ -> nil
      end
    else
      nil
    end
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
  Deletes a player and all associated sessions.

  ## Examples

      iex> delete_player(player)
      {:ok, %Player{}}

      iex> delete_player(player)
      {:error, %Ecto.Changeset{}}

  """
  def delete_player(%Player{} = player) do
    from(s in "sessions", where: s.player_id == ^player.id) |> Repo.delete_all()
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

  @doc """
  Begins login flow for a person given a phone number.

  If a player with the provided phone number exists, we text
  a verification code to the phone number and return a successful response.

  After receiving the verification code, a person can complete the login flow with `login_verify`.
  """
  def login(phone_number) when is_binary(phone_number) do
    case Player.parse_phone_number_input(phone_number) do
      {:error, message} ->
        {:error, message}

      {:ok, parsed_phone_number} ->
        player = get_player_by_phone_number(parsed_phone_number)

        if player == nil do
          {:error, "No player found for that phone number"}
        else
          verification_code = gen_verification_code()

          now = NaiveDateTime.utc_now()
          # Clean up orphaned sessions while we're here so this table doesn't grow out of control
          from(s in "sessions",
            where: s.expires_at <= ^now or is_nil(s.hashed_token)
          )
          |> Repo.delete_all()

          %Session{}
          |> Session.changeset(%{
            player_id: player.id,
            expires_at: four_weeks_from_now(),
            hashed_verification_code: verification_code |> salt_and_hash(parsed_phone_number)
          })
          |> Repo.insert!()

          BeaconBall.Notifications.Twilio.send_sms(
            parsed_phone_number,
            "Beacon Ball verification code: #{verification_code}"
          )

          {:ok, parsed_phone_number}
        end
    end
  end

  def login_verify(phone_number, verification_code) do
    hashed_code = salt_and_hash(verification_code, phone_number)

    case Repo.get_by(Session, hashed_verification_code: hashed_code) do
      nil ->
        {:error, "Unrecognized verification code"}

      session ->
        token = gen_session_token()

        session
        |> Session.changeset(%{hashed_token: hash_session_token(token)})
        |> Repo.update!()

        {:ok, token}
    end
  end

  defp four_weeks_from_now do
    NaiveDateTime.add(NaiveDateTime.utc_now(), 1 * 60 * 60 * 24 * 28, :second)
  end

  defp gen_verification_code do
    rand_digit = fn -> :rand.uniform(10) - 1 end
    "#{rand_digit.()}#{rand_digit.()}#{rand_digit.()}#{rand_digit.()}"
  end

  defp gen_session_token do
    Ecto.UUID.generate()
  end

  defp hash_session_token(token) when is_binary(token) do
    # Session tokens are UUIDs, therefore no salt is needed since they are unique.
    salt_and_hash(token, "")
  end

  defp salt_and_hash(value, salt) do
    :crypto.hash(:sha256, "#{value}#{salt}") |> Base.encode16()
  end
end

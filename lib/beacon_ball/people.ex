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
    if session == nil, do: nil, else: Repo.get(Player, session.player_id)
  end

  def get_session_by_token(token) when is_binary(token) do
    session = Repo.get_by(Session, hashed_token: Session.hash_session_token(token))

    # Only return player if session is not expired
    if session == nil or Session.is_session_expired?(session), do: nil, else: session
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
          # Clean up orphaned sessions while we're here so the sessions table doesn't grow out of control
          Session.clean_orphaned_sessions(player.id)

          verification_code = Session.gen_verification_code()
          Session.create_unverified_session(player.id, parsed_phone_number, verification_code)

          with {:error, message} <-
                 BeaconBall.Notifications.Twilio.send_sms(
                   parsed_phone_number,
                   "Beacon Ball verification code: #{verification_code}"
                 ) do
            IO.puts("Error sending SMS: #{message}")
          end

          {:ok, parsed_phone_number}
        end
    end
  end

  def login_verify(phone_number, verification_code) do
    hashed_code = Session.salt_and_hash(verification_code, phone_number)

    case Repo.get_by(Session, hashed_verification_code: hashed_code) do
      nil ->
        {:error, "Unrecognized verification code"}

      session ->
        token = Session.verify_session(session)
        {:ok, token}
    end
  end

  def logout(token) do
    hashed_token = Session.hash_session_token(token)

    from(s in "sessions",
      where: s.hashed_token == ^hashed_token
    )
    |> Repo.delete_all()
  end
end

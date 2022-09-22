defmodule BeaconBall.People.Session do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query, warn: false

  alias BeaconBall.Repo

  schema "sessions" do
    field :player_id, :integer
    field :expires_at, :naive_datetime
    field :hashed_token, :string
    field :hashed_verification_code, :string

    timestamps()
  end

  @doc false
  def changeset(session, attrs) do
    session
    |> cast(attrs, [:player_id, :expires_at, :hashed_token, :hashed_verification_code])
    |> validate_required([:player_id, :expires_at, :hashed_verification_code])
    |> unique_constraint(:hashed_token)
    |> unique_constraint(:hashed_verification_code)
  end

  def create_unverified_session(player_id, phone_number, verification_code) do
    %__MODULE__{}
    |> changeset(%{
      player_id: player_id,
      expires_at: four_weeks_from_now(),
      hashed_verification_code: verification_code |> salt_and_hash(phone_number)
    })
    |> Repo.insert!()
  end

  defp four_weeks_from_now do
    NaiveDateTime.add(NaiveDateTime.utc_now(), 1 * 60 * 60 * 24 * 28, :second)
  end

  def verify_session(session) do
    token = gen_session_token()

    session
    |> changeset(%{hashed_token: hash_session_token(token)})
    |> Repo.update!()

    token
  end

  def clean_orphaned_sessions(player_id) do
    now = NaiveDateTime.utc_now()

    from(s in "sessions",
      where: s.player_id == ^player_id and (s.expires_at <= ^now or is_nil(s.hashed_token))
    )
    |> Repo.delete_all()
  end

  def gen_verification_code do
    rand_digit = fn -> :rand.uniform(10) - 1 end
    "#{rand_digit.()}#{rand_digit.()}#{rand_digit.()}#{rand_digit.()}"
  end

  defp gen_session_token do
    Ecto.UUID.generate()
  end

  def hash_session_token(token) when is_binary(token) do
    # Session tokens are UUIDs, therefore no salt is needed since they are unique.
    salt_and_hash(token, "")
  end

  def salt_and_hash(value, salt) do
    :crypto.hash(:sha256, "#{value}#{salt}") |> Base.encode16()
  end

  def is_session_expired?(session) do
    NaiveDateTime.compare(session.expires_at, NaiveDateTime.utc_now()) != :gt
  end
end

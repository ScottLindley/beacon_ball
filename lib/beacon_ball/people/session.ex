defmodule BeaconBall.People.Session do
  use Ecto.Schema
  import Ecto.Changeset

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
end

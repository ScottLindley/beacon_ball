defmodule BeaconBall.People.Session do
  use Ecto.Schema
  import Ecto.Changeset

  schema "sessions" do
    field :expires_at, :naive_datetime
    field :hashed_token, :string
    field :hashed_verification_code, :string
    belongs_to(:player, BeaconBall.People.Player)

    timestamps()
  end

  @doc false
  def changeset(session, attrs) do
    session
    |> cast(attrs, [:expires_at, :hashed_token, :hashed_verification_code])
    |> validate_required([:expires_at, :hashed_verification_code])
    |> unique_constraint(:hashed_token)
    |> unique_constraint(:hashed_verification_code)
    |> Ecto.Changeset.assoc_constraint(:player)
  end
end

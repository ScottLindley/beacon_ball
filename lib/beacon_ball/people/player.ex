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
    |> unique_constraint(:phone_number)
  end
end

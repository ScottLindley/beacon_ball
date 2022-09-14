defmodule BeaconBall.Runs.Run do
  use Ecto.Schema
  import Ecto.Changeset

  schema "runs" do
    field :max_capacity, :integer
    field :message, :string
    field :starts_at, :naive_datetime

    timestamps()
  end

  @doc false
  def changeset(run, attrs) do
    run
    |> cast(attrs, [:starts_at, :max_capacity, :message])
    |> validate_required([:starts_at, :max_capacity, :message])
  end
end

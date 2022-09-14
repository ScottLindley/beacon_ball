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
    |> validate_required([:starts_at, :max_capacity])
    |> validate_number(:max_capacity, greater_than: 0)
    |> validate_date_in_future(:starts_at)
  end

  defp validate_date_in_future(changeset, field) do
    now = NaiveDateTime.utc_now()

    date =
      case get_field(changeset, field) do
        nil -> now
        d -> d
      end

    case NaiveDateTime.compare(date, now) do
      :gt -> changeset
      _ -> add_error(changeset, field, "Cannot schedule a run to start in the past")
    end
  end
end

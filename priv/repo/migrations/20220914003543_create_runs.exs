defmodule BeaconBall.Repo.Migrations.CreateRuns do
  use Ecto.Migration

  def change do
    create table(:runs) do
      add :starts_at, :naive_datetime, null: false
      add :max_capacity, :integer, null: false
      add :message, :string

      timestamps()
    end
  end
end

defmodule BeaconBall.Repo.Migrations.CreatePlayers do
  use Ecto.Migration

  def change do
    create table(:players) do
      add :name, :string, null: false
      add :phone_number, :bigint, null: false
      add :is_admin, :boolean, default: false, null: false

      timestamps()
    end

    create unique_index(:players, [:phone_number])
  end
end

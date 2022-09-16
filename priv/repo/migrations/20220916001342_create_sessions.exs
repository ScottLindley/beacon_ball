defmodule BeaconBall.Repo.Migrations.CreateSessions do
  use Ecto.Migration

  def change do
    create table(:sessions) do
      add :player_id, references("players"), null: false
      add :hashed_token, :string
      add :expires_at, :naive_datetime, null: false
      add :hashed_verification_code, :string, null: false

      timestamps()
    end

    create index(:sessions, :player_id)
    create unique_index(:sessions, :hashed_token)
    create unique_index(:sessions, :hashed_verification_code)
  end
end

defmodule BeaconBall.Repo do
  use Ecto.Repo,
    otp_app: :beacon_ball,
    adapter: Ecto.Adapters.Postgres
end

defmodule BeaconBall.RunsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `BeaconBall.Runs` context.
  """

  @doc """
  Generate a run.
  """
  def run_fixture(attrs \\ %{}) do
    {:ok, run} =
      attrs
      |> Enum.into(%{
        max_capacity: 42,
        message: "some message",
        starts_at: ~N[2022-09-13 00:35:00]
      })
      |> BeaconBall.Runs.create_run()

    run
  end
end

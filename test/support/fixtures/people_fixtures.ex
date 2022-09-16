defmodule BeaconBall.PeopleFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `BeaconBall.People` context.
  """

  @doc """
  Generate a player.
  """
  def player_fixture(attrs \\ %{}) do
    {:ok, player} =
      attrs
      |> Enum.into(%{
        is_admin: true,
        name: "some name",
        phone_number: 42
      })
      |> BeaconBall.People.create_player()

    player
  end
end

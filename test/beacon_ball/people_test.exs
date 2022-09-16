defmodule BeaconBall.PeopleTest do
  use BeaconBall.DataCase

  alias BeaconBall.People

  describe "players" do
    alias BeaconBall.People.Player

    import BeaconBall.PeopleFixtures

    @invalid_attrs %{is_admin: nil, name: nil, phone_number: nil}

    test "list_players/0 returns all players" do
      player = player_fixture()
      assert People.list_players() == [player]
    end

    test "get_player!/1 returns the player with given id" do
      player = player_fixture()
      assert People.get_player!(player.id) == player
    end

    test "create_player/1 with valid data creates a player" do
      valid_attrs = %{is_admin: true, name: "some name", phone_number: 42}

      assert {:ok, %Player{} = player} = People.create_player(valid_attrs)
      assert player.is_admin == true
      assert player.name == "some name"
      assert player.phone_number == 42
    end

    test "create_player/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = People.create_player(@invalid_attrs)
    end

    test "update_player/2 with valid data updates the player" do
      player = player_fixture()
      update_attrs = %{is_admin: false, name: "some updated name", phone_number: 43}

      assert {:ok, %Player{} = player} = People.update_player(player, update_attrs)
      assert player.is_admin == false
      assert player.name == "some updated name"
      assert player.phone_number == 43
    end

    test "update_player/2 with invalid data returns error changeset" do
      player = player_fixture()
      assert {:error, %Ecto.Changeset{}} = People.update_player(player, @invalid_attrs)
      assert player == People.get_player!(player.id)
    end

    test "delete_player/1 deletes the player" do
      player = player_fixture()
      assert {:ok, %Player{}} = People.delete_player(player)
      assert_raise Ecto.NoResultsError, fn -> People.get_player!(player.id) end
    end

    test "change_player/1 returns a player changeset" do
      player = player_fixture()
      assert %Ecto.Changeset{} = People.change_player(player)
    end
  end
end

defmodule BeaconBall.RunsTest do
  use BeaconBall.DataCase

  alias BeaconBall.Runs

  describe "runs" do
    alias BeaconBall.Runs.Run

    import BeaconBall.RunsFixtures

    @invalid_attrs %{max_capacity: nil, message: nil, starts_at: nil}

    test "list_runs/0 returns all runs" do
      run = run_fixture()
      assert Runs.list_runs() == [run]
    end

    test "get_run!/1 returns the run with given id" do
      run = run_fixture()
      assert Runs.get_run!(run.id) == run
    end

    test "create_run/1 with valid data creates a run" do
      valid_attrs = %{
        max_capacity: 42,
        message: "some message",
        starts_at: ~N[3022-09-13 00:35:00]
      }

      assert {:ok, %Run{} = run} = Runs.create_run(valid_attrs)
      assert run.max_capacity == 42
      assert run.message == "some message"
      assert run.starts_at == ~N[3022-09-13 00:35:00]
    end

    test "create_run/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Runs.create_run(@invalid_attrs)
      # Test for `starts_at` date time that is in the past
      assert {:error, %Ecto.Changeset{}} =
               Runs.create_run(%{@invalid_attrs | starts_at: NaiveDateTime.utc_now()})
    end

    test "update_run/2 with valid data updates the run" do
      run = run_fixture()

      update_attrs = %{
        max_capacity: 43,
        message: "some updated message",
        starts_at: ~N[3022-09-14 00:35:00]
      }

      assert {:ok, %Run{} = run} = Runs.update_run(run, update_attrs)
      assert run.max_capacity == 43
      assert run.message == "some updated message"
      assert run.starts_at == ~N[3022-09-14 00:35:00]
    end

    test "update_run/2 with invalid data returns error changeset" do
      run = run_fixture()
      assert {:error, %Ecto.Changeset{}} = Runs.update_run(run, @invalid_attrs)
      assert run == Runs.get_run!(run.id)
      # Test for `starts_at` date time that is in the past
      assert {:error, %Ecto.Changeset{}} =
               Runs.update_run(run, %{@invalid_attrs | starts_at: NaiveDateTime.utc_now()})

      assert run == Runs.get_run!(run.id)
    end

    test "delete_run/1 deletes the run" do
      run = run_fixture()
      assert {:ok, %Run{}} = Runs.delete_run(run)
      assert_raise Ecto.NoResultsError, fn -> Runs.get_run!(run.id) end
    end

    test "change_run/1 returns a run changeset" do
      run = run_fixture()
      assert %Ecto.Changeset{} = Runs.change_run(run)
    end
  end
end

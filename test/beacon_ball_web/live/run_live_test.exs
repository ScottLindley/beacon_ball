defmodule BeaconBallWeb.RunLiveTest do
  use BeaconBallWeb.ConnCase

  import Phoenix.LiveViewTest
  import BeaconBall.RunsFixtures

  @create_attrs %{max_capacity: 42, message: "some message", starts_at: %{day: 13, hour: 0, minute: 35, month: 9, year: 2022}}
  @update_attrs %{max_capacity: 43, message: "some updated message", starts_at: %{day: 14, hour: 0, minute: 35, month: 9, year: 2022}}
  @invalid_attrs %{max_capacity: nil, message: nil, starts_at: %{day: 30, hour: 0, minute: 35, month: 2, year: 2022}}

  defp create_run(_) do
    run = run_fixture()
    %{run: run}
  end

  describe "Index" do
    setup [:create_run]

    test "lists all runs", %{conn: conn, run: run} do
      {:ok, _index_live, html} = live(conn, Routes.run_index_path(conn, :index))

      assert html =~ "Listing Runs"
      assert html =~ run.message
    end

    test "saves new run", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, Routes.run_index_path(conn, :index))

      assert index_live |> element("a", "New Run") |> render_click() =~
               "New Run"

      assert_patch(index_live, Routes.run_index_path(conn, :new))

      assert index_live
             |> form("#run-form", run: @invalid_attrs)
             |> render_change() =~ "is invalid"

      {:ok, _, html} =
        index_live
        |> form("#run-form", run: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.run_index_path(conn, :index))

      assert html =~ "Run created successfully"
      assert html =~ "some message"
    end

    test "updates run in listing", %{conn: conn, run: run} do
      {:ok, index_live, _html} = live(conn, Routes.run_index_path(conn, :index))

      assert index_live |> element("#run-#{run.id} a", "Edit") |> render_click() =~
               "Edit Run"

      assert_patch(index_live, Routes.run_index_path(conn, :edit, run))

      assert index_live
             |> form("#run-form", run: @invalid_attrs)
             |> render_change() =~ "is invalid"

      {:ok, _, html} =
        index_live
        |> form("#run-form", run: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.run_index_path(conn, :index))

      assert html =~ "Run updated successfully"
      assert html =~ "some updated message"
    end

    test "deletes run in listing", %{conn: conn, run: run} do
      {:ok, index_live, _html} = live(conn, Routes.run_index_path(conn, :index))

      assert index_live |> element("#run-#{run.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#run-#{run.id}")
    end
  end

  describe "Show" do
    setup [:create_run]

    test "displays run", %{conn: conn, run: run} do
      {:ok, _show_live, html} = live(conn, Routes.run_show_path(conn, :show, run))

      assert html =~ "Show Run"
      assert html =~ run.message
    end

    test "updates run within modal", %{conn: conn, run: run} do
      {:ok, show_live, _html} = live(conn, Routes.run_show_path(conn, :show, run))

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Run"

      assert_patch(show_live, Routes.run_show_path(conn, :edit, run))

      assert show_live
             |> form("#run-form", run: @invalid_attrs)
             |> render_change() =~ "is invalid"

      {:ok, _, html} =
        show_live
        |> form("#run-form", run: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.run_show_path(conn, :show, run))

      assert html =~ "Run updated successfully"
      assert html =~ "some updated message"
    end
  end
end

defmodule UploaderGWeb.LogLiveTest do
  use UploaderGWeb.ConnCase

  import Phoenix.LiveViewTest
  import UploaderG.LoggingFixtures

  @create_attrs %{
    event: "some event",
    logged_at: %{day: 10, hour: 14, minute: 47, month: 2, year: 2022},
    message: "some message",
    uuid: "some uuid"
  }
  @update_attrs %{
    event: "some updated event",
    logged_at: %{day: 11, hour: 14, minute: 47, month: 2, year: 2022},
    message: "some updated message",
    uuid: "some updated uuid"
  }
  @invalid_attrs %{
    event: nil,
    logged_at: %{day: 30, hour: 14, minute: 47, month: 2, year: 2022},
    message: nil,
    uuid: nil
  }

  defp create_log(_) do
    log = log_fixture()
    %{log: log}
  end

  describe "Index" do
    setup [:create_log]

    test "lists all logs", %{conn: conn, log: log} do
      {:ok, _index_live, html} = live(conn, Routes.log_index_path(conn, :index))

      assert html =~ "Listing Logs"
      assert html =~ log.event
    end

    test "saves new log", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, Routes.log_index_path(conn, :index))

      assert index_live |> element("a", "New Log") |> render_click() =~
               "New Log"

      assert_patch(index_live, Routes.log_index_path(conn, :new))

      assert index_live
             |> form("#log-form", log: @invalid_attrs)
             |> render_change() =~ "is invalid"

      {:ok, _, html} =
        index_live
        |> form("#log-form", log: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.log_index_path(conn, :index))

      assert html =~ "Log created successfully"
      assert html =~ "some event"
    end

    test "updates log in listing", %{conn: conn, log: log} do
      {:ok, index_live, _html} = live(conn, Routes.log_index_path(conn, :index))

      assert index_live |> element("#log-#{log.id} a", "Edit") |> render_click() =~
               "Edit Log"

      assert_patch(index_live, Routes.log_index_path(conn, :edit, log))

      assert index_live
             |> form("#log-form", log: @invalid_attrs)
             |> render_change() =~ "is invalid"

      {:ok, _, html} =
        index_live
        |> form("#log-form", log: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.log_index_path(conn, :index))

      assert html =~ "Log updated successfully"
      assert html =~ "some updated event"
    end

    test "deletes log in listing", %{conn: conn, log: log} do
      {:ok, index_live, _html} = live(conn, Routes.log_index_path(conn, :index))

      assert index_live |> element("#log-#{log.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#log-#{log.id}")
    end
  end

  describe "Show" do
    setup [:create_log]

    test "displays log", %{conn: conn, log: log} do
      {:ok, _show_live, html} = live(conn, Routes.log_show_path(conn, :show, log))

      assert html =~ "Show Log"
      assert html =~ log.event
    end

    test "updates log within modal", %{conn: conn, log: log} do
      {:ok, show_live, _html} = live(conn, Routes.log_show_path(conn, :show, log))

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Log"

      assert_patch(show_live, Routes.log_show_path(conn, :edit, log))

      assert show_live
             |> form("#log-form", log: @invalid_attrs)
             |> render_change() =~ "is invalid"

      {:ok, _, html} =
        show_live
        |> form("#log-form", log: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.log_show_path(conn, :show, log))

      assert html =~ "Log updated successfully"
      assert html =~ "some updated event"
    end
  end
end

defmodule UploaderGWeb.TransmissionLiveTest do
  use UploaderGWeb.ConnCase

  import Phoenix.LiveViewTest
  import UploaderG.OperationFixtures

  @create_attrs %{
    checksum: "some checksum",
    destination: "some destination",
    end: %{day: 10, hour: 14, minute: 39, month: 2, year: 2022},
    origin: "some origin",
    size: 42,
    start: %{day: 10, hour: 14, minute: 39, month: 2, year: 2022},
    status: "some status",
    uuid: "some uuid"
  }
  @update_attrs %{
    checksum: "some updated checksum",
    destination: "some updated destination",
    end: %{day: 11, hour: 14, minute: 39, month: 2, year: 2022},
    origin: "some updated origin",
    size: 43,
    start: %{day: 11, hour: 14, minute: 39, month: 2, year: 2022},
    status: "some updated status",
    uuid: "some updated uuid"
  }
  @invalid_attrs %{
    checksum: nil,
    destination: nil,
    end: %{day: 30, hour: 14, minute: 39, month: 2, year: 2022},
    origin: nil,
    size: nil,
    start: %{day: 30, hour: 14, minute: 39, month: 2, year: 2022},
    status: nil,
    uuid: nil
  }

  defp create_transmission(_) do
    transmission = transmission_fixture()
    %{transmission: transmission}
  end

  describe "Index" do
    setup [:create_transmission]

    test "lists all transmissions", %{conn: conn, transmission: transmission} do
      {:ok, _index_live, html} = live(conn, Routes.transmission_index_path(conn, :index))

      assert html =~ "Listing Transmissions"
      assert html =~ transmission.checksum
    end

    test "saves new transmission", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, Routes.transmission_index_path(conn, :index))

      assert index_live |> element("a", "New Transmission") |> render_click() =~
               "New Transmission"

      assert_patch(index_live, Routes.transmission_index_path(conn, :new))

      assert index_live
             |> form("#transmission-form", transmission: @invalid_attrs)
             |> render_change() =~ "is invalid"

      {:ok, _, html} =
        index_live
        |> form("#transmission-form", transmission: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.transmission_index_path(conn, :index))

      assert html =~ "Transmission created successfully"
      assert html =~ "some checksum"
    end

    test "updates transmission in listing", %{conn: conn, transmission: transmission} do
      {:ok, index_live, _html} = live(conn, Routes.transmission_index_path(conn, :index))

      assert index_live |> element("#transmission-#{transmission.id} a", "Edit") |> render_click() =~
               "Edit Transmission"

      assert_patch(index_live, Routes.transmission_index_path(conn, :edit, transmission))

      assert index_live
             |> form("#transmission-form", transmission: @invalid_attrs)
             |> render_change() =~ "is invalid"

      {:ok, _, html} =
        index_live
        |> form("#transmission-form", transmission: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.transmission_index_path(conn, :index))

      assert html =~ "Transmission updated successfully"
      assert html =~ "some updated checksum"
    end

    test "deletes transmission in listing", %{conn: conn, transmission: transmission} do
      {:ok, index_live, _html} = live(conn, Routes.transmission_index_path(conn, :index))

      assert index_live
             |> element("#transmission-#{transmission.id} a", "Delete")
             |> render_click()

      refute has_element?(index_live, "#transmission-#{transmission.id}")
    end
  end

  describe "Show" do
    setup [:create_transmission]

    test "displays transmission", %{conn: conn, transmission: transmission} do
      {:ok, _show_live, html} =
        live(conn, Routes.transmission_show_path(conn, :show, transmission))

      assert html =~ "Show Transmission"
      assert html =~ transmission.checksum
    end

    test "updates transmission within modal", %{conn: conn, transmission: transmission} do
      {:ok, show_live, _html} =
        live(conn, Routes.transmission_show_path(conn, :show, transmission))

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Transmission"

      assert_patch(show_live, Routes.transmission_show_path(conn, :edit, transmission))

      assert show_live
             |> form("#transmission-form", transmission: @invalid_attrs)
             |> render_change() =~ "is invalid"

      {:ok, _, html} =
        show_live
        |> form("#transmission-form", transmission: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.transmission_show_path(conn, :show, transmission))

      assert html =~ "Transmission updated successfully"
      assert html =~ "some updated checksum"
    end
  end
end

defmodule UploaderTWeb.ModalityLiveTest do
  use UploaderTWeb.ConnCase

  import Phoenix.LiveViewTest
  import UploaderT.CRUDFixtures

  @create_attrs %{ip: "some ip", location: "some location", name: "some name", port: 42}
  @update_attrs %{
    ip: "some updated ip",
    location: "some updated location",
    name: "some updated name",
    port: 43
  }
  @invalid_attrs %{ip: nil, location: nil, name: nil, port: nil}

  defp create_modality(_) do
    modality = modality_fixture()
    %{modality: modality}
  end

  describe "Index" do
    setup [:create_modality]

    test "lists all modalities", %{conn: conn, modality: modality} do
      {:ok, _index_live, html} = live(conn, Routes.modality_index_path(conn, :index))

      assert html =~ "Listing Modalities"
      assert html =~ modality.ip
    end

    test "saves new modality", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, Routes.modality_index_path(conn, :index))

      assert index_live |> element("a", "New Modality") |> render_click() =~
               "New Modality"

      assert_patch(index_live, Routes.modality_index_path(conn, :new))

      assert index_live
             |> form("#modality-form", modality: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#modality-form", modality: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.modality_index_path(conn, :index))

      assert html =~ "Modality created successfully"
      assert html =~ "some ip"
    end

    test "updates modality in listing", %{conn: conn, modality: modality} do
      {:ok, index_live, _html} = live(conn, Routes.modality_index_path(conn, :index))

      assert index_live |> element("#modality-#{modality.id} a", "Edit") |> render_click() =~
               "Edit Modality"

      assert_patch(index_live, Routes.modality_index_path(conn, :edit, modality))

      assert index_live
             |> form("#modality-form", modality: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#modality-form", modality: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.modality_index_path(conn, :index))

      assert html =~ "Modality updated successfully"
      assert html =~ "some updated ip"
    end

    test "deletes modality in listing", %{conn: conn, modality: modality} do
      {:ok, index_live, _html} = live(conn, Routes.modality_index_path(conn, :index))

      assert index_live |> element("#modality-#{modality.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#modality-#{modality.id}")
    end
  end

  describe "Show" do
    setup [:create_modality]

    test "displays modality", %{conn: conn, modality: modality} do
      {:ok, _show_live, html} = live(conn, Routes.modality_show_path(conn, :show, modality))

      assert html =~ "Show Modality"
      assert html =~ modality.ip
    end

    test "updates modality within modal", %{conn: conn, modality: modality} do
      {:ok, show_live, _html} = live(conn, Routes.modality_show_path(conn, :show, modality))

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Modality"

      assert_patch(show_live, Routes.modality_show_path(conn, :edit, modality))

      assert show_live
             |> form("#modality-form", modality: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        show_live
        |> form("#modality-form", modality: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.modality_show_path(conn, :show, modality))

      assert html =~ "Modality updated successfully"
      assert html =~ "some updated ip"
    end
  end
end

defmodule ElcWeb.PageLiveTest do
  use ElcWeb.ConnCase

  import Phoenix.LiveViewTest

  test "disconnected and connected render", %{conn: conn} do
    {:ok, page_live, disconnected_html} = live(conn, "/")
    assert disconnected_html =~ "elixir"
    assert render(page_live) =~ "elixir"
  end
end

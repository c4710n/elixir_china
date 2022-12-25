defmodule ElixirChinaWeb.HomeLive do
  use ElixirChinaWeb, :live_view
  alias ElixirChinaWeb.OnlineVisitor
  alias ElixirChinaWeb.OnlineVisitorComponent

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      OnlineVisitor.subscribe()
    end

    {:ok,
     socket
     |> assign(:browser_id, "fake_browser_id")
     |> assign(:online_visitor_component_id, "online_visitors"), layout: false}
  end

  @impl true
  def handle_params(_url, _params, socket) do
    maybe_track_visitor(socket)
    {:noreply, socket}
  end

  @impl true
  def handle_info(%{event: "presence_diff"}, socket) do
    %{online_visitor_component_id: online_visitor_component_id} = socket.assigns
    send_update(OnlineVisitorComponent, id: online_visitor_component_id)

    {:noreply, socket}
  end

  defp maybe_track_visitor(socket) do
    if connected?(socket) do
      {:ok, _} = OnlineVisitor.track_visitor(self(), socket.assigns.browser_id)
    end
  end
end

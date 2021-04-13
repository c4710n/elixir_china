defmodule ElcWeb.PageLive do
  use ElcWeb, :live_view
  alias ElcWeb.Presence

  @impl true
  def mount(_params, session, socket) do
    if connected?(socket) do
      Presence.subscribe()
    end

    {:ok,
     socket
     |> assign_defaults(session)
     |> assign(:online_users_component_id, "online_users")}
  end

  @impl true
  def handle_params(_url, _params, socket) do
    maybe_track_user(socket)
    {:noreply, socket}
  end

  @impl true
  def handle_info(%{event: "presence_diff"}, socket) do
    send_update(ElcWeb.OnlineUsersComponent, id: socket.assigns.online_users_component_id)
    {:noreply, socket}
  end

  defp maybe_track_user(socket) do
    if connected?(socket) do
      {:ok, _} = Presence.track_user(self(), socket.assigns.browser_id)
    end
  end
end

defmodule ElcWeb.OnlineUsersComponent do
  use ElcWeb, :live_component

  alias ElcWeb.Presence

  @impl true
  def update(_assigns, socket) do
    {:ok,
     socket
     |> assign_online_users()}
  end

  @impl true
  def render(assigns) do
    ~L"""
    <p>Online User <%= length @online_users %></p>
    """
  end

  defp assign_online_users(socket) do
    users =
      Presence.list_users()
      |> Enum.map(fn {uid, %{metas: metas}} -> {uid, metas} end)

    assign(socket, :online_users, users)
  end
end

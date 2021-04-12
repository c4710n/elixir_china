defmodule ElcWeb.MountHelpers do
  import Phoenix.LiveView, only: [assign: 3]

  def assign_defaults(socket) do
    socket
    |> assign_session_id(session)
  end

  defp assign_session_id(socket, session) do
    assign(socket, :session_id, session["live_socket_id"])
  end
end

defmodule ElixirChinaWeb.OnlineVisitor do
  alias ElixirChinaWeb.Endpoint
  alias ElixirChinaWeb.Presence

  @topic "visitor:online"

  def track_visitor(pid, key) do
    Presence.track(pid, @topic, key, %{
      online_at: System.system_time(:second)
    })
  end

  def list_visitors() do
    Presence.list(@topic)
  end

  def subscribe() do
    Endpoint.subscribe(@topic)
  end
end

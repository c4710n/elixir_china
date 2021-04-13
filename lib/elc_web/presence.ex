defmodule ElcWeb.Presence do
  use Phoenix.Presence,
    otp_app: :elc,
    pubsub_server: Elc.PubSub

  alias ElcWeb.Endpoint

  @user_presence_topic "presence_state"

  @doc false
  def track_user(pid, uid) do
    __MODULE__.track(pid, @user_presence_topic, uid, %{
      online_at: System.system_time(:second)
    })
  end

  @doc false
  def list_users() do
    __MODULE__.list(@user_presence_topic)
  end

  @doc false
  def subscribe() do
    Endpoint.subscribe(@user_presence_topic)
  end
end

defmodule ElixirChinaWeb.OnlineVisitorComponent do
  use ElixirChinaWeb, :live_component
  alias ElixirChinaWeb.OnlineVisitor

  @impl true
  def update(_assigns, socket) do
    {:ok,
     socket
     |> assign_count_of_visitors()}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class={[
      "fixed bottom-1 right-1 px-4 py-2",
      "border border-neutral-200 bg-neutral-50 rounded-lg",
      "opacity-50 hover:opacity-100 transition duration-250 ease-in-out"
    ]}>
      <p class="text-neutral-500">当前在线访客 <%= @count_of_visitors %></p>
    </div>
    """
  end

  defp assign_count_of_visitors(socket) do
    count =
      OnlineVisitor.list_visitors()
      |> Enum.count()

    assign(socket, :count_of_visitors, count)
  end
end

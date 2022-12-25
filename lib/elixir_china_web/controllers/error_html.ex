defmodule ElixirChinaWeb.ErrorHTML do
  use ElixirChinaWeb, :html

  # If you want to customize your error pages,
  # uncomment the embed_templates/1 call below
  # and add pages to the error directory:
  #
  #   * lib/elixir_china_web/controllers/error_html/404.html.heex
  #   * lib/elixir_china_web/controllers/error_html/500.html.heex
  #

  embed_templates "error_html/*"

  # render the fallback template
  def render(template, assigns) do
    status = assigns.status
    message = Phoenix.Controller.status_message_from_template(template)
    fallback(%{status: status, message: message})
  end
end

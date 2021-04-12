defmodule Elc.Repo do
  use Ecto.Repo,
    otp_app: :elc,
    adapter: Ecto.Adapters.Postgres
end

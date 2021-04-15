import Config
import Retro.ConfigHelper

if config_env() != :test do
  database_url =
    System.get_env("DATABASE_URL") ||
      raise """
      environment variable DATABASE_URL is missing.
      For example: ecto://USER:PASS@HOST/DATABASE
      """

  config :elc, Elc.Repo,
    # ssl: true,
    url: database_url,
    pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10")

  secret_key_base =
    System.get_env("SECRET_KEY_BASE") ||
      raise """
      environment variable SECRET_KEY_BASE is missing.
      You can generate one by calling: mix phx.gen.secret
      """

  base_url =
    System.get_env("BASE_URL") ||
      raise """
      environment variable BASE_URL is missing.
      Setup it as something like `https://example.com/`.
      """

  config :elc, ElcWeb.Endpoint,
    url: parse_phoenix_endpoint_url(base_url),
    check_origin: [base_url],
    http: [
      port: String.to_integer(System.get_env("PORT") || "4000"),
      transport_options: [socket_opts: [:inet6]]
    ],
    secret_key_base: secret_key_base
end

if System.get_env("RELEASE_MODE") do
  config :elc, ElcWeb.Endpoint, server: true
end

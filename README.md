# ElixirChina

[![built with nix](https://builtwithnix.org/badge.svg)](https://builtwithnix.org)

> Promot Elixir in China, and guide more chinese developers to international community.

To start your Phoenix server:

- Run `mix setup` to install and setup dependencies
- Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).

## Docker

### Build image

```console
$ nix build .#dockerImage --system x86_64-linux
```

### Push image

```console
$ $(nix build .#dockerImage --system x86_64-linux) | docker load
```

## Online Version

Visit <https://elixir-china.zekedou.live>.

## Learn more

- Official website: https://www.phoenixframework.org/
- Guides: https://hexdocs.pm/phoenix/overview.html
- Docs: https://hexdocs.pm/phoenix
- Forum: https://elixirforum.com/c/phoenix-forum
- Source: https://github.com/phoenixframework/phoenix

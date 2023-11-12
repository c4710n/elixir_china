# ElixirChina

[![built with nix](https://builtwithnix.org/badge.svg)](https://builtwithnix.org)

> Promot Elixir in China, and guide more chinese developers to international community.

## Online Version

Visit <https://elixir-china.zekedou.live>.

## Development

To start your Phoenix server:

- Run `mix setup` to install and setup dependencies
- Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

## Deployment

### Mix Release

```
$ nix build '.#release'
```

### Docker Image

#### Build image

```console
# build x86_64-linux image on x86_64-linux host
$ nix build .#packages.x86_64-linux.docker-image-triggered-by-x86_64-linux

# build x86_64-linux image on x86_64-darwin host
$ nix build .#packages.x86_64-linux.docker-image-triggered-by-x86_64-darwin

# build x86_64-linux image on aarch64-darwin host
$ nix build .#packages.x86_64-linux.docker-image-triggered-by-aarch64-darwin

# ...
# run `nix flake show` to show more packages
```

#### Push image

```console
$ result | docker load
```

## License

MIT

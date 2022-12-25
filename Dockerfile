# Dockerfile for Phoenix project.
#
# Useful links:
# - available images: https://hub.docker.com/r/hexpm/elixir/tags?name=alpine
# - finding packages: https://pkgs.org/

# > Global args
# https://github.com/moby/moby/issues/37345#issuecomment-400245466

# customizable args
ARG ELIXIR_VERSION=1.14.2
ARG ERLANG_VERSION=25.1.2
ARG ALPINE_VERSION=3.17.0

ARG BUILDER_IMAGE="hexpm/elixir:${ELIXIR_VERSION}-erlang-${ERLANG_VERSION}-alpine-${ALPINE_VERSION}"
ARG RUNNER_IMAGE="alpine:${ALPINE_VERSION}"

ARG RELEASE_NAME=elixir_china

# internal args
ARG MIX_ENV=prod
ARG WORK_DIR=/app
ARG ASSETS_DIR=assets
ARG CONFIG_DIR=config
ARG USER=elixir


# > Prepare
FROM ${BUILDER_IMAGE} AS builder

# args
ARG MIX_ENV
ARG WORK_DIR
ARG ASSETS_DIR
ARG CONFIG_DIR

# setup build envs
ENV MIX_ENV $MIX_ENV

# prepare build dir
WORKDIR $WORK_DIR

# install build dependencies
RUN apk add --no-cache \
  build-base \
  git \
  nodejs \
  npm

# install mix dependencies
RUN mix local.hex --force
RUN mix local.rebar --force
COPY mix.exs mix.lock ./
RUN mix deps.get --only $MIX_ENV

# install npm dependencies
COPY $ASSETS_DIR/package.json \
  $ASSETS_DIR/package-lock.json \
  $ASSETS_DIR/
RUN npm install --prefix $ASSETS_DIR

# compile mix deps
RUN mkdir -p $CONFIG_DIR
# copy compile-time config files before we compile dependencies to ensure any
# relevant config change will trigger the dependencies to be re-compiled.
COPY $CONFIG_DIR/config.exs $CONFIG_DIR/$MIX_ENV.exs $CONFIG_DIR/
RUN mix deps.compile

# copy source code
COPY priv priv
COPY lib lib
COPY assets assets

# compile application
RUN mix compile

# compile assets
RUN mix assets.deploy

# assemble release
# changes to config/runtime.exs don't require recompiling the code
COPY $CONFIG_DIR/runtime.exs $CONFIG_DIR/
COPY rel rel
RUN mix release


# > Final
FROM ${RUNNER_IMAGE}

# args
ARG RELEASE_NAME
ARG MIX_ENV
ARG WORK_DIR
ARG USER

# setup envs
ENV HOME $WORK_DIR
ENV USER $USER

# prepare work dir
WORKDIR $WORK_DIR

# install dependencies
RUN apk add --no-cache \
  ncurses-libs \
  libgcc libstdc++ \
  openssl \
  curl \
  && update-ca-certificates --fresh

# create an unprivileged user
RUN \
  addgroup \
    -g 1000 \
    -S \
    "$USER" \
  && adduser \
     -u 1000 \
     -G "$USER" \
     -h "$WORK_DIR" \
     -s /bin/sh \
     -D \
     "$USER"

# limit permissions
USER "$USER":"$USER"

# copy release
COPY --from=builder \
  --chown="$USER":"$USER" \
  $WORK_DIR/_build/$MIX_ENV/rel/$RELEASE_NAME ./

CMD ["bin/server"]

# Appended by flyctl
ENV ECTO_IPV6 true
ENV ERL_AFLAGS "-proto_dist inet6_tcp"

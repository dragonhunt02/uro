ARG ELIXIR_VERSION=1.16

# Elixir build environment.
FROM elixir:${ELIXIR_VERSION}-alpine as elixir-base

ARG MIX_ENV=prod

ENV MIX_ENV=${MIX_ENV} \
	COMPILE_PHASE=true

WORKDIR /app

RUN apk add --no-cache \
	nodejs \
	npm \
	inotify-tools \
	git \
	bash \
	make \
	gcc \
	curl \
	libc-dev

RUN mix local.hex --force && \
	mix local.rebar --force

COPY mix.exs mix.lock ./
RUN mix do deps.get

# Apply patches
RUN git config --worktree user.email "git-patches@github" \
  git config --worktree user.name "git-patches" \
  git config --worktree commit.gpgsign false \
  find "patches/" -type f -name '*.patch' -exec \
    git am --committer-date-is-author-date "{}" \;

RUN mix do patch.exmarcel, deps.compile

COPY config ./config
COPY priv ./priv
COPY lib ./lib

RUN mix do compile, phx.digest
RUN mix uro.apigen

EXPOSE ${PORT}

ENV COMPILE_PHASE=false
ENTRYPOINT iex -S mix do ecto.migrate, phx.server

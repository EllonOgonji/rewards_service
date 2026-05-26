FROM elixir:1.16-alpine AS build
RUN apk add --no-cache build-base git
WORKDIR /app

# Install hex + rebar
RUN mix local.hex --force && \
    mix local.rebar --force

COPY mix.exs mix.lock ./
RUN mix do deps.get --only prod, deps.compile

COPY . .
RUN MIX_ENV=prod mix do compile, release

FROM alpine:3.19
RUN apk add --no-cache openssl libstdc++ ncurses
WORKDIR /app
COPY --from=build /app/_build/prod/rel/rewards_service ./

ENV HOST="0.0.0.0"
ENV PORT=4000

CMD ["bin/rewards_service", "start"]

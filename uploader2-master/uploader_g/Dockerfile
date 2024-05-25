FROM elixir:1.13

# Apt
RUN apt update --fix-missing && apt upgrade -y
RUN apt install -y apt-utils
RUN apt install -y build-essential
RUN apt install -y inotify-tools
RUN apt install -y postgresql-client
RUN apt install -y openssh-server

RUN mix local.hex --force
RUN mix local.rebar --force

WORKDIR /app

# COPY ./app/mix.exs .
# COPY ./app/mix.lock .
# COPY ./app .

# RUN mix deps.get 
# RUN mix ecto.create
# RUN mix do compile

# CMD ["mix", "phx.server"]
# CMD mix phx.server

CMD ["/app/entrypoint.sh"]

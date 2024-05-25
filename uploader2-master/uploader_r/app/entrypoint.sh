#!/bin/bash
# Docker entrypoint script (Shell Script).

FOLDERS="decrypted decompressed observable"

for i in $FOLDERS; do
    if [ ! -d /app/$i ]; then
       # Take action if $i exists. #
       echo "creating $i..."
       mkdir /app/$i
    fi
done

mix deps.get

# Wait until Postgres is ready.
while ! pg_isready -q -h $POSTGRES_HOST -p $POSTGRES_PORT -U $POSTGRES_USER
do
  echo "$(date) - waiting for database to start"
  sleep 2
done

mix ecto.create
mix ecto.migrate

# Create, migrate, and seed database if it doesn't exist.
# if [[ -z `psql -Atqc "\\list $PGDATABASE"` ]]; then
#   echo "Database $PGDATABASE does not exist. Creating..."
#   createdb -E UTF8 $PGDATABASE -l en_US.UTF-8 -T template0
#   mix ecto.migrate
#   mix run priv/repo/seeds.exs
#   echo "Database $PGDATABASE created."
# fi

# exec storescp -b STORESCP:7000 --directory /dev/null &

exec mix phx.server

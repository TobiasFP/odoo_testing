#!/bin/bash

set -e

# set the postgres database host, port, user and password according to the environment
# and pass them as arguments to the odoo process if not present in the config file
: ${HOST:=${DB_PORT_5432_TCP_ADDR:='db'}}
: ${PORT:=${DB_PORT_5432_TCP_PORT:=5432}}
: ${USER:=${DB_ENV_POSTGRES_USER:=${POSTGRES_USER:='odoo'}}}
: ${PASSWORD:=${DB_ENV_POSTGRES_PASSWORD:=${POSTGRES_PASSWORD:='odoo'}}}
if [ "$env_ODOO_TESTING" == "true" ]; then
  odooTestRun="odoo --test-enable --dev=all"
  addTestVar="--test-enable"
  addDevVar="--dev=all"
fi
echo "printenv: "
echo $odooTestRun

DB_ARGS=()
function check_config() {
    param="$1"
    value="$2"
    if ! grep -q -E "^\s*\b${param}\b\s*=" "$ODOO_RC" ; then
        DB_ARGS+=("--${param}")
        DB_ARGS+=("${value}")
   fi;
}
check_config "db_host" "$HOST"
check_config "db_port" "$PORT"
check_config "db_user" "$USER"
check_config "db_password" "$PASSWORD"

case "$1" in
    -- | odoo)
        shift
        if [[ "$1" == "scaffold" ]] ; then
	    echo "Running scaffold"
            exec odoo "$@"
        else
	          echo "Running 2"
            exec odoo "$addTestVar" "$addDevVar" "${DB_ARGS[@]}"
        fi
        ;;
    -*)
	      echo "Running 3"
        exec odoo "$@" "${DB_ARGS[@]}"
        ;;
    *)
        if [ -z "$odooTestRun" ]; then
	  echo "running odooTestRun"
          exec "$odooTestRun"
        else
          exec "$@"
        fi
esac

exit 1

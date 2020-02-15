#!/bin/sh

su -c "export USER_ENV_TIMEFRAME=$USER_ENV_TIMEFRAME && /home/$APP_USER/run-dry.sh" $APP_USER

exec "$@"

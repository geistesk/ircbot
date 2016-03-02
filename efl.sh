#!/bin/sh
# Eval Fail Loop for deploying software like it's 1990
#
# Usage: ./efl.sh [ENV]
# where ENV could be "dev" or "prod" (default)

[ "$#" == "1" ] && ENV="$1" || ENV="prod"

MIX_ENV="$ENV" mix compile

while [ true ]; do
  echo "Starting IrcBot[$ENV].."
  MIX_ENV="$ENV" mix run --no-halt
  echo "IrcBot has stopped. Restart in 20sec."
  sleep 20
done

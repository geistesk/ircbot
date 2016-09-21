#!/bin/sh
# Usage: ./run.sh [ENV]
# where ENV could be "dev" or "prod" (default)

[ "$#" == "1" ] && ENV="$1" || ENV="prod"
cd `dirname $0`

MIX_ENV="$ENV" mix compile
MIX_ENV="$ENV" mix run --no-halt

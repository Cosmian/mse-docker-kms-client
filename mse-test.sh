#!/bin/bash

set -e

usage() {
    echo "mse-test usage: $0 --application <module:application> [--debug] "
    echo ""
    echo "Example: $0 --application app:app --debug"
    exit 1
}

set_default_variables() {
    APPLICATION=""
    CODE_PATH="/app/code"
    DEBUG=""
}

parse_args() {
    echo "Reading args: $*"
    # Parse args
    while [[ $# -gt 0 ]]; do
        case $1 in
            --application)
            APPLICATION="$2"
            shift # past argument
            shift # past value
            ;;
            --debug)
            DEBUG="--debug"
            shift # past argument
            ;;
            -*)
            usage
            ;;
        esac
    done

    if [ -z "$APPLICATION" ]
    then
        echo "You must provide the path to the WSGI/ASGI application"
        exit 1
    fi
}

set_default_variables
parse_args "$@"

# Don't write .pyc files
export PYTHONDONTWRITEBYTECODE=1
# Other directory for __pycache__ folders
export PYTHONPYCACHEPREFIX=/tmp

# Install dependencies
if [ -e "$CODE_PATH/requirements.txt" ]; then
    echo "Installing deps..."
    pip install -r $CODE_PATH/requirements.txt
fi

pushd $CODE_PATH

if [ -z "$DEBUG" ]; then
    PYTHONPATH="." flask --app "$APPLICATION" run --host=0.0.0.0
else
    PYTHONPATH="." flask --app "$APPLICATION" "$DEBUG" run --host=0.0.0.0
fi

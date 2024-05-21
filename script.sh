#!/bin/bash

list_users() {
    awk -F: '($3 >= 1000 && $1 != "nobody") { print $1 ": " $6 }' /etc/passwd | sort
}

list_processes() {
    ps -e --sort pid
}

show_help() {
    echo "Usage: $0 [OPTIONS]"
    echo "Options:"
    echo "  -u, --users          List users and their home directories"
    echo "  -p, --processes      List running processes"
    echo "  -h, --help           Show this help message"
    echo "  -l, --log PATH       Redirect output to file at PATH"
    echo "  -e, --errors PATH    Redirect errors to file at PATH"
}

check_access() {
    local path=$1
    if [[ ! -w $path ]]; then
        echo "Error: No write access to $path" >&2
        exit 1
    fi
}

LOG_PATH=""
ERROR_PATH=""

TEMP=$(getopt -o uphl:e: --long users,processes,help,log:,errors: -n 'parse-options' -- "$@")
eval set -- "$TEMP"

while true; do
    case "$1" in
        -u | --users )
            ACTION="users"; shift ;;
        -p | --processes )
            ACTION="processes"; shift ;;
        -h | --help )
            ACTION="help"; shift ;;
        -l | --log )
            LOG_PATH=$2; shift 2 ;;
        -e | --errors )
            ERROR_PATH=$2; shift 2 ;;
        -- )
            shift; break ;;
        * )
            break ;;
    esac
done

[[ -n $LOG_PATH ]] && check_access $LOG_PATH
[[ -n $ERROR_PATH ]] && check_access $ERROR_PATH

[[ -n $LOG_PATH ]] && exec > "$LOG_PATH"
[[ -n $ERROR_PATH ]] && exec 2> "$ERROR_PATH"

case $ACTION in
    "users" )
        list_users ;;
    "processes" )
        list_processes ;;
    "help" )
        show_help ;;
    * )
        echo "Invalid option. Use -h or --help for usage information." >&2
        exit 1 ;;
esac

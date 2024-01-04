#!/bin/bash

# Text Colors
BLACK='\033[0;30m'
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[0;37m'

# Bold Text Colors
BOLD_BLACK='\033[1;30m'
BOLD_RED='\033[1;31m'
BOLD_GREEN='\033[1;32m'
BOLD_YELLOW='\033[1;33m'
BOLD_BLUE='\033[1;34m'
BOLD_MAGENTA='\033[1;35m'
BOLD_CYAN='\033[1;36m'
BOLD_WHITE='\033[1;37m'

# Reset Color
NC='\033[0m'

# Icons
GEAR="${BOLD_CYAN}⚙ ${NC}"

usage() {
  cat <<-EOF
Usage: $(basename "$0") <subcommand> [options]
Subcommands:
  create         Create plugin
    -s SERVICE_NAME   Specify service name
    -p PLUGIN_NAME    Specify plugin name
    -c CONFIG_DATA    Specify configuration data
  update-conf    Update configuration
    -s SERVICE_NAME   Specify service name
    -i PLUGIN_ID      Specify plugin ID
    -c CONFIG_DATA    Specify configuration data
  -h             Display this help message
  -v             Verbose
EOF
  exit 0
}

usage_create() {
  cat <<-EOF
Usage: $(basename "$0") create [options]
  create         Create something
    -s SERVICE_NAME   Specify service name
    -p PLUGIN_NAME    Specify plugin name
    -c CONFIG_DATA    Specify configuration data
    -h                Display this help message
EOF
  exit 0
}

usage_update() {
  cat <<-EOF
Usage: $(basename "$0") update-conf [options]
  update-conf         Update plugin configurations
    -s SERVICE_NAME   Specify service name
    -p PLUGIN_NAME    Specify plugin name
    -c CONFIG_DATA    Specify configuration data
    -h                Display this help message
EOF
  exit 0
}

create() {
  local service_name=$1
  local plugin_name=$2
  local config_data=$3

  if [[ $verbose == true ]]; then
    echo
    echo "${GEAR}${BOLD_BLUE}Service Name:${NC} ${service_name}"
    echo "${GEAR}${BOLD_BLUE}Plugin Name:${NC} ${plugin_name}"
    echo "${GEAR}${BOLD_BLUE}Config Data:${NC} ${config_data}"
    echo
  fi

  curl -i -X POST --url "http://localhost:8001/services/${service_name}" --data "name=${plugin_name}" --data "config=${config_data}"
}

update_conf() {
  local service_name="$1"
  local plugin_id="$2"
  local config_data="$3"

  echo "Executing 'update-conf' subcommand"
  echo "Service Name: $service_name"
  echo "Plugin ID: $plugin_id"
  echo "Config Data: $config_data"

  curl -i -X PUT --url "http://localhost:8001/services/${service_name}/plugins/${plugin_id}" --data "config=${new_config_data}"
}

if [ $# -eq 0 ]; then
  usage
  exit 1
fi

while getopts ":hv" opt; do # Go through the options
  case $opt in
  h) # Help
    usage
    exit 0 # Exit correctly
    ;;
  v) # Debug
    echo "Verbose flag"
    verbose=true
    ;;
  ?) # Invalid option
    echo "[ERROR]: Invalid option: -${OPTARG}"
    usage
    exit 1 # Exit with error
    ;;
  esac
done

shift $((OPTIND - 1))
subcommand="$1"

case $subcommand in
create)
  if [[ $verbose == true ]]; then
    echo "${BOLD_GREEN}ℹ ${NC}${YELLOW}Execute create subcommand${NC}"
  fi

  while getopts ":s:p:c:h:" opt; do
    case $opt in
    s)
      service_name="$OPTARG"
      ;;
    p)
      plugin_name="$OPTARG"
      ;;
    c)
      config_data="$OPTARG"
      ;;
    h)
      usage_create
      ;;
    \?)
      echo "Invalid option: -$OPTARG"
      exit 1
      ;;
    :)
      echo "Option -$OPTARG requires an argument."
      exit 1
      ;;
    esac
  done

  create "$service_name" "$plugin_name" "$config_data"
  ;;
update-conf)
  if [[ $verbose == true ]]; then echo "Execute update-conf subcommand"; fi

  while getopts ":s:i:c:h" opt; do
    case $opt in
    s)
      service_name="$OPTARG"
      ;;
    i)
      plugin_id="$OPTARG"
      ;;
    c)
      config_data="$OPTARG"
      ;;
    h)
      usage_update
      ;;
    \?)
      echo "Invalid option: -$OPTARG"
      exit 1
      ;;
    :)
      echo "Option -$OPTARG requires an argument."
      exit 1
      ;;
    esac
  done

  update_conf "$service_name" "$plugin_id" "$config_data"
  ;;
*)
  echo "Unknown subcommand: $subcommand"
  usage
  ;;
esac

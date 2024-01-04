#!/bin/bash

create() {
  local service_name=$1
  local plugin_name=$2
  local config_data=$3

  # Create a new plugin for the specified service
  curl -i -X POST --url "http://localhost:8001/services/${service_name}/plugins/" --data "name=${plugin_name}" --data "config=${config_data}"
}

update_conf() {
  local service_name=$1
  local plugin_id=$2
  local new_config_data=$3

  # Update the configuration of an existing plugin
  curl -i -X PUT --url "http://localhost:8001/services/${service_name}/plugins/${plugin_id}" --data "config=${new_config_data}"
}

while getopts ":s:p:c:i:n:-:" opt; do
  case $opt in
  s) service_name="$OPTARG" ;;
  p) plugin_name="$OPTARG" ;;
  c) config_data="$OPTARG" ;;
  i) plugin_id="$OPTARG" ;;
  n) new_config_data="$OPTARG" ;;
  -)
    case "${OPTARG}" in
    service-name)
      service_name="$2"
      shift 2
      ;;
    plugin-name)
      plugin_name="$2"
      shift 2
      ;;
    config-data)
      config_data="$2"
      shift 2
      ;;
    plugin-id)
      plugin_id="$2"
      shift 2
      ;;
    new-config-data)
      new_config_data="$2"
      shift 2
      ;;
    *)
      echo "Invalid option: --$OPTARG" >&2
      exit 1
      ;;
    esac
    ;;
  \?)
    echo "Invalid option: -$OPTARG" >&2
    exit 1
    ;;
  :)
    echo "Option -$OPTARG requires an argument." >&2
    exit 1
    ;;
  esac
done

shift $((OPTIND - 1))

case "$1" in
create-service)
  if [[ -z "$service_name" || -z "$plugin_name" || -z "$config_data" ]]; then
    echo "Usage: $0 create-service --service-name <service-name> --config-data <config-data>"
    exit 1
  fi

  create_service "${service_name}" "${config_data}"
  ;;
update-conf)
  if [[ -z "$service_name" || -z "$plugin_id" || -z "$new_config_data" ]]; then
    echo "Usage: $0 update-conf --service-name <service-name> --plugin-id <plugin-id> --new-config-data <new-config-data>"
    exit 1
  fi

  update_conf "${service_name}" "${plugin_id}" "${new_config_data}"
  ;;
*)
  echo "Usage: $0 {create|update-conf}"
  exit 1
  ;;
esac

#!/usr/bin/env bash

set -a # Automatically export all variables
source .env
set +a

self=$0
pull_image=false # pull required image every time start

function log() {
    local ts
    ts=$(date '+%Y-%m-%dT%H:%M:%S')
    echo "$ts--LOG--$@"
}

function clean() {
    # clean database of influxdb and volume of grafana
    log "cleaning influxdb database"
    rm -rf "${INFLUXDB_ENGINE:?}"/engine
    rm -rf "${INFLUXDB_CONFIG:?}"/influx-configs

    log "deleting grafana volume $GRAFANA_VOLUME"
    docker volume rm "$GRAFANA_VOLUME"
}

function generate_datasource_yaml() {
    local template_file="$1"
    local output_file="$2"

    echo "Generating datasource YAML from template..."
    if [ -f "$template_file" ]; then
        # Read the template file and generate the output file
        cp "$template_file" "$output_file"
        if [ $? -ne 0 ]; then
            echo "Failed to copy template file to output file."
            return 1
        fi

        # Perform substitutions
        sed -i "s|{{INFLUXDB_URL}}|${INFLUXDB_URL}|g" "$output_file"
        sed -i "s|{{INFLUXDB_INIT_TOKEN}}|${INFLUXDB_INIT_TOKEN}|g" "$output_file"
        sed -i "s|{{INFLUXDB_BUCKET}}|${INFLUXDB_BUCKET}|g" "$output_file"
        sed -i "s|{{INFLUXDB_ORG}}|${INFLUXDB_ORG}|g" "$output_file"

        if [ $? -ne 0 ]; then
            echo "Failed to perform substitutions in output file."
            return 1
        fi

        echo "Datasource YAML generated successfully."
    else
        echo "Template file does not exist: $template_file"
        return 1
    fi
}


function prepare_grafana() {
    log "checking docker volume $GRAFANA_VOLUME"
    if ! docker volume inspect "$GRAFANA_VOLUME" >/dev/null 2>&1; then
        log "creating docker volume $GRAFANA_VOLUME"
        docker volume create --name "$GRAFANA_VOLUME"
    fi
    if [ "$pull_image" = true ]; then
        log "pull the latest image $GRAFANA_IMAGE"
        docker compose pull grafana
    fi

    log "substituting environment variables in Grafana provisioning files"
    generate_datasource_yaml "$GRAFANA_PROVISIONING/datasources/default.yaml.template" "$GRAFANA_PROVISIONING/datasources/default.yaml"
}

function prepare_influxdb() {
    if [ ! -d "$INFLUXDB_ENGINE" ]; then
        log "influxdb database folder does not exist, creating one"
        mkdir -p "$INFLUXDB_ENGINE"
    fi
    if [ "$pull_image" = true ]; then
        log "pull the required version of image $INFLUXDB_IMAGE"
        docker compose pull influxdb
    fi
}

function check_influxdb () {
    # check if influxdb is ready for connection
    log "waiting for influxdb getting ready"
    while true; do
        result=$(curl --noproxy '*' -w '%{http_code}' --silent --output /dev/null http://localhost:8086/api/v2/setup)
        if [ "$result" -eq 200 ]; then
            log "influxdb is online!"
            break
        fi
        sleep 3
    done
}

function setup_influxdb() {
    # initialize influxdb
    result=$(curl --silent http://localhost:8086/api/v2/setup)
    if [[ $result == *"true"* ]]; then
        log "influxdb is not initialized, setup influxdb"
        docker exec influxdb influx setup \
            --org "$INFLUXDB_ORG" \
            --bucket "$INFLUXDB_BUCKET" \
            --username "$INFLUXDB_USER" \
            --password "$INFLUXDB_PASSWD" \
            --token "$INFLUXDB_INIT_TOKEN" \
            --retention 2h \
            --force
    fi
}

function start() {
    if ! docker --version >/dev/null 2>&1; then
        log "docker is not installed, exiting"
        exit 1
    fi
    prepare_influxdb
    prepare_grafana
    log "starting docker containers"
    docker compose up -d 
    check_influxdb
    setup_influxdb
}

function stop () {
    log "stopping docker containers"
    docker compose stop
}

case "$1" in
    start)
        start
        ;;
    stop)
        stop
        ;;
    clean)
        clean
        ;;
    *)
        echo "Usage: $0 {start|stop|clean}"
        exit 1
esac
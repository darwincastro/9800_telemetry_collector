# 9800 Telemetry Collector

## Introduction

This repository facilitates the setup of a telemetry collection system tailored for Cisco IOS-XE C9800s Wireless Controllers. It employs Docker Compose to orchestrate three essential containers:

- **Telegraf:** Collects data.
- **InfluxDB:** Stores time-series data.
- **Grafana:** Visualizes the data.

The Docker Compose file automates the deployment of these components, streamlining the process to be zero-touch. It includes provisions for creating InfluxDB buckets and Grafana dashboards.

## Requirements

- docker-ce
- docker-compose version >= 2.0.0
- Linux distribution (For MacOS, see Known Issues)

## Steps to Get It Up and Running

1. **Clone the Repo**

```bash
git clone http://github.com/darwincastro/9800_telemetry_collector.git
```

2. **Navigate to the Directory**

```bash
cd 9800_telemetry_collector
```

3. **Edit the .env File**

Use a text editor to modify the `.env` file, replacing the IP address under the variable `INFLUXDB_URL` with the host's IP address.

```bash
nano .env
```

4. **Run the script build.sh**

```bash
sudo ./build.sh start
```

5. **Configure Wireless Controller Telemetry**

Refer to <a href="https://github.com/darwincastro/9800_telemetry_collector/blob/master/examples/subscription.cfg" target="_blank">this link</a> for an example of wireless controller telemetry configuration.

6. **Access GUI**

   - Grafana: `http://<ip_address_of_host>:3000` (Login: admin/admin123)
   - InfluxDB: `http://<ip_address_of_host>:8086` (Login: admin/admin123)

7. **Pre-built Dashboards**

   - Demo 9800CL
   - Demo 9800L
   - Demo 9840
   - Demo 9880

## Troubleshooting

**Docker:**

If containers fail to run:

```bash
docker ps -a # Determine problem exit code
docker run -it --entrypoint /bin/bash $IMAGE_NAME -s # Investigate container
```

Ensure containers stay up:

```bash
# Point docker file to tail -f /dev/null if no entry point or service is running
```

**Wireless Controller:**

Verify requisite processes:

```bash
show platform software yang-management process
```

Validate telemetry configuration:

```bash
show running-config | section telemetry
```

Check subscription validity:

```bash
show telemetry ietf subscription all
```

Check receiver validity:

```bash
show telemetry receiver all
```

Verify telemetry subscription states:

```bash
show telemetry internal subscription all stats
```

## Known Issues

- MacOS uses the BSD version of sed by default, which doesn't work with this script. Use `brew install gnu-sed` to install the GNU version of sed if running this script on MacOS.

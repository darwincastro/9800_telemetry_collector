# 9800 Telemetry TIG-Stack

## Introduction

This repository facilitates the setup of a telemetry collection system tailored for Cisco IOS-XE C9800s Wireless Controllers. It employs Docker Compose to orchestrate three essential containers:

- **Telegraf:** Collects data.
- **InfluxDB:** Stores time-series data.
- **Grafana:** Visualizes the data.

The Docker Compose file automates the deployment of these components, streamlining the process to be zero-touch. It includes provisions for creating InfluxDB buckets and Grafana dashboards.

## Screenshot
![9840_demo_dashboard](https://github.com/darwincastro/9800_telemetry_collector/blob/master/examples/9840-Demo-Dasboard.png)

## Requirements

- [Docker Engine](https://docs.docker.com/engine/install/ubuntu/)
- Linux distribution (For MacOS, see Known Issues)

> [!IMPORTANT]  
> If you are using Docker for deploying this TIG-Stack setup, please ensure that your Docker Compose version is equal to or greater than 2.0.0. Older versions of Docker Compose may not fully support the configuration syntax used in this setup.
> You can check your Docker Compose version by running:
> ```bash
> docker-compose --version
> ```

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

Refer to <a href="https://github.com/darwincastro/9800_telemetry_collector/blob/master/examples/" target="_blank">this link</a> for an example of wireless controller telemetry configuration.

6. **Access GUI**

   - Grafana: `http://<ip_address_of_host>:3000` (Login: admin/C1sco12345)
   - InfluxDB: `http://<ip_address_of_host>:8086` (Login: admin/C1sco12345)

> [!NOTE]  
> Do Not Use LOCALHOST/127.0.0.1 - You Must Use a Reachable IP Address

7. **Pre-built Dashboards**

   - Demo 9800CL
   - Demo 9800L
   - Demo 9840

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
Confirm that Telegraf is receiving telemetry data from the Cisco C9800:

```bash
docker exec -it telegraf tail -f /tmp/metrics.out
```

Check the logs of each container:

```bash
docker logs influxdb
docker logs telegraf
docker logs grafana
```

Check telegraf's internal metrics:

```bash
# Open and edit telegraf.conf
cd /etc/telegraf
nano telegraf.conf

# Add the following lines at the end to monitor the health
[[inputs.internal]]
  collect_memstats = true

[agent]
  debug = true
# Save the changes

# Display logs for Tegraf
docker logs telegraf
```

> [!TIP]
> Addressing these points should help you identify where the problem is occurring in your TIG stack setup.

Cleanup:

If you want to remove the TIG-Stack containers or if something went wrong during the installation, you can run the following script:

```bash
sudo ./cleanup.sh
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

## License

This project is licensed under the MIT License. See the [LICENSE](./LICENSE) file for details.


## Known Issues

- MacOS uses the BSD version of sed by default, which doesn't work with this script. Use `brew install gnu-sed` to install the GNU version of sed if running this script on MacOS.

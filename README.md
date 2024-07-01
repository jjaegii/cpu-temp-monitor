# CPU Temperature Monitoring with Docker

## Overview

This guide explains how to build and run a Docker container that monitors CPU temperature. When the temperature of `Package id 0` exceeds 70°C, the container will send an email alert using Gmail's SMTP server.

## Prerequisites

1. Docker installed on your system.
2. A Gmail account with an app password created. You can create an app password [here](https://myaccount.google.com/security).

## How to execute

### 1. Build and Run the Docker Image

#### Prepare Dockerfile and monitor.sh

Ensure you have the `Dockerfile` and `monitor.sh` files in your working directory.

#### Build the Docker Image

Open a terminal and navigate to the directory containing the `Dockerfile` and `monitor.sh`. Run the following command to build the Docker image:

```sh
docker build -t your-dockerhub-username/cpu-monitor:latest .
```

Replace `your-dockerhub-username` with your actual Docker Hub username.

#### Run the Docker Container

Execute the following command to run the Docker container. Replace the environment variables with your actual values:

```sh
docker run -d \
  --name cpu-monitor \
  -e SMTP_HOST=smtp.gmail.com \
  -e SMTP_PORT=587 \
  -e SMTP_USER=your-email@gmail.com \
  -e SMTP_PASS=your-app-password \
  -e EMAIL_TO=recipient@example.com \
  your-dockerhub-username/cpu-monitor:latest
```

Environment variables:
- `SMTP_HOST`: SMTP server address (Gmail: `smtp.gmail.com`)
- `SMTP_PORT`: SMTP server port (Gmail: `587`)
- `SMTP_USER`: Your Gmail address
- `SMTP_PASS`: Your Gmail app password
- `EMAIL_TO`: The recipient's email address for the alerts

#### Verify the Container

Check if the container is running correctly:

```sh
docker ps
```

You should see a container named `cpu-monitor` in the list of running containers.

#### Check the Logs

To verify that the script is running and check for any errors, view the container logs:

```sh
docker logs cpu-monitor
```

### 2. Pull and Run the Image from Docker Hub

Instead of building the image, you can directly pull it from Docker Hub.

#### Pull the Docker Image

Use the following command to pull the image from Docker Hub:

```sh
docker pull jjaegii/cpu-monitor:latest
```

#### Run the Docker Container

Execute the following command to run the Docker container:

```sh
docker run -d \
  --name cpu-monitor \
  -e SMTP_HOST=smtp.gmail.com \
  -e SMTP_PORT=587 \
  -e SMTP_USER=your-email@gmail.com \
  -e SMTP_PASS=your-app-password \
  -e EMAIL_TO=recipient@example.com \
  jjaegii/cpu-monitor:latest
```

### 3. Deploy to Kubernetes

Use the `deployment.yaml` file to deploy to a Kubernetes cluster.

#### deployment.yaml File

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: cpu-monitor
  labels:
    app: cpu-monitor
spec:
  replicas: 1
  selector:
    matchLabels:
      app: cpu-monitor
  template:
    metadata:
      labels:
        app: cpu-monitor
    spec:
      containers:
      - name: cpu-monitor
        image: jjaegii/cpu-monitor:latest
        env:
        - name: SMTP_HOST
          value: "smtp.gmail.com"
        - name: SMTP_PORT
          value: "587"
        - name: SMTP_USER
          value: "your-email@gmail.com"
        - name: SMTP_PASS
          value: "your-app-password"
        - name: EMAIL_TO
          value: "recipient@example.com"
```

#### Deploy to Kubernetes

Use the following command to deploy to the Kubernetes cluster:

```sh
kubectl apply -f deployment.yaml
```

## Additional Information

- Ensure that your Docker daemon has access to the sensors. Depending on your system configuration, you might need to run the container with elevated privileges.
- The monitoring script checks the temperature every 60 seconds. Adjust the sleep duration in the `monitor.sh` script if you need a different frequency.

## Troubleshooting

- If you encounter authentication issues with Gmail, ensure that the app password is correct and that your Gmail account settings allow access from less secure apps if needed.
- Verify that the `sensors` command is available and provides the expected output on your host system. You might need to install `lm-sensors` on your host.


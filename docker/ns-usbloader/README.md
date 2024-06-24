# ns-usbloader

This repository contains a Dockerfile and example Docker Compose configuration to run ns-usbloader through a web browser using noVNC.

## Prerequisites

Before running the Docker container, make sure you have the following installed:

- Docker
- Docker Compose

## Usage

1. Clone this repository:

    ```shell
    git clone https://github.com/your-username/ns-usbloader.git
    ```

2. Build the Docker image:

    ```shell
    docker build -t ns-usbloader .
    ```

3. Run the Docker container:

    ```shell
    docker run -d -p 8080:8080 ns-usbloader
    ```

4. Access ns-usbloader in your web browser:

    ```
    http://localhost:8080
    ```

## Docker Compose

Here's an example Docker Compose configuration to run ns-usbloader:

```yaml
version: '3'
services:
  ns-usbloader:
     build:
        context: .
        dockerfile: Dockerfile
     ports:
        - 8080:8080
```

Save the above configuration in a file named `docker-compose.yml`, and then run the following command to start the container:

```shell
docker-compose up -d
```

You can access ns-usbloader in your web browser at `http://localhost:8080`.

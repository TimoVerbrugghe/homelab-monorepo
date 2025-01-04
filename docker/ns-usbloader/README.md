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
    docker run -d -p 8080:8080 -v /path/to/nsp/files:/nsp -v /path/to/config:/root/.java/.userPrefs/NS-USBloader ghcr.io/timoverbrugghe/ns-usbloader
    ```

4. Access ns-usbloader in your web browser:

    ```
    http://localhost:8080
    ```

## Docker Compose

Here's an example Docker Compose configuration to run ns-usbloader:

```yaml
services:
  ns-usbloader:
    image: ghcr.io/timoverbrugghe/ns-usbloader
    ports:
      - 8080:8080
    volumes:
      - /path/to/nsp/files:/nsp
      - /path/to/config:/root/.java/.userPrefs/NS-USBloader
```

Save the above configuration in a file named `docker-compose.yaml`, and then run the following command to start the container:

```shell
docker-compose up -d
```

You can access ns-usbloader in your web browser at `http://localhost:8080`.
```

## Configure ns-usbloader

Before installing games using ns-usbloader, you need to configure the port and IP settings. Follow these steps:

1. Open ns-usbloader in your web browser by accessing `http://localhost:8080`.

2. Navigate to the settings page.

3. Set the port to `6042` and the IP to your host IP address.

4. Save the settings.

Now you can proceed with installing games using ns-usbloader.

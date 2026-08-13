<div align="center">
<img src="https://raw.githubusercontent.com/ai4os/ai4-docs/refs/heads/master/source/_static/images/ai4eosc/logo.png" alt="logo" width="300"/>
</div>

# AI4OS Development Environment (AI4OSDev)

[![Build Status](https://jenkins.services.ai4os.eu/buildStatus/icon?job=AI4OS/ai4os-dev-env/main)](https://jenkins.services.ai4os.eu/job/AI4OS/job/ai4os-dev-env/job/main)
[![Contributor Covenant](https://img.shields.io/badge/Contributor%20Covenant-1.4-4baaaa.svg)](CODE_OF_CONDUCT.md)

This is a containerized development environment for AI/ML workloads on AI4EOSC-like platforms. It provides **JupyterLab**, **VSCode (code-server)**, and the **DEEPaaS API** component. There is **no application code** inside -- you bring your own code!

You can either:
- Mount a host volume with your code into the container, or
- Use git inside the container to pull your code 

Develop using JupyterLab or VSCode and test your application immediately in the cloud environment, and when ready, commit your changes back to your repository.

The resulting Docker image has pre-installed (Aug-2026):
* TensorFlow or PyTorch or NVIDIA CUDA or (just) Ubuntu
* [deepaas](https://github.com/ai4os/DEEPaaS) ≥2.1.0
* [deep-start](https://github.com/ai4os/deep-start) launcher script
* [flaat](https://github.com/indigo-dc/flaat)
* Development IDE: 
   * JupyterLab
   * VSCode ([code-server](https://github.com/coder/code-server))
* Python: python3, pip3
* (cloud) File management:
   * [rclone](https://rclone.org) (cloud storage sync - S3, Nextcloud, Google Drive, 40+ backends)
   * [oneclient](https://onedata.org) (Onedata access)
* Archive tools: unzip, zip, bzip2
* Monitoring & debugging: htop, iputils-ping, net-tools
* [cookiecutter](https://github.com/cookiecutter/cookiecutter)
* git, git-lfs
* curl, wget, jq
* mc, nano
* [oidc-agent](https://github.com/indigo-dc/oidc-agent)
* openssh-client


## Running the container

### Directly from Docker Hub

#### Default: JupyterLab

```bash
$ docker run -ti -p 5000:5000 -p 6006:6006 -p 8888:8888 ai4oshub/ai4os-dev-env
```

This starts JupyterLab (default). Access at: http://127.0.0.1:8888

#### Alternative: VSCode (code-server)

```bash
$ docker run -ti -p 5000:5000 -p 6006:6006 -p 8888:8888 \
    -e PASSWORD=your_secure_password \
    ai4oshub/ai4os-dev-env deep-start -s
```

Access VSCode at: http://127.0.0.1:8888

⚠️ **Important**: The `PASSWORD` environment variable is **required** for VSCode in cloud deployments.

#### DEEPaaS API Only

To start only the DEEPaaS API service (without IDE):

```bash
$ docker run -ti -p 5000:5000 -p 6006:6006 ai4oshub/ai4os-dev-env deep-start
```
Access at: http://127.0.0.1:5000  (or http://127.0.0.1:5000/api to get Swagger interface)

💡 **Hint:**: You can start DEEPaaS API also in either Jupyterlab or VSCode: go to terminal and execute `deep-start`, then direct your browser to http://127.0.0.1:5000/api to access DEEPaaS API Swagger interface.

#### Mount Host Volumes

Mount your local code directory into the container:

```bash
$ docker run -ti -p 8888:8888 \
    -v $HOME/my-project:/srv/app/my-project \
    ai4oshub/ai4os-dev-env
```

This mounts your host directory `$HOME/my-project` into the container at `/srv/app/my-project`.

**Note**: For both CPU-based and GPU-based images, you can also use [udocker](https://github.com/indigo-dc/udocker) to run containers.

### Running via docker-compose

The `docker-compose.yml` file provides pre-configured services for different scenarios:

```bash
$ docker-compose up generic-cpu          # JupyterLab on CPU
$ docker-compose up generic-cpu-vscode   # VSCode on CPU
$ docker-compose up generic-gpu          # JupyterLab on GPU (requires nvidia-docker)
$ docker-compose up generic-gpu-vscode   # VSCode on GPU (requires nvidia-docker)
```

**Requirements:**
- Docker 17.06.0+ and docker-compose 1.16.0+
- For GPU support: you need [nvidia-container-toolkit](https://github.com/NVIDIA/nvidia-container-toolkit)


### Building the container

If you want to build the container directly in your machine (because you want
to modify the `Dockerfile` for instance) follow the following instructions:

Building the container:

1. Get the `ai4os-dev-env` repository:

    ```bash
    $ git clone https://github.com/ai4os/ai4os-dev-env
    ```

2. Build the container:

    ```bash
    $ cd ai4os-dev-env
    $ docker build -t ai4oshub/ai4os-dev-env .
    ```

These two steps will download the repository from GitHub and will build the
Docker container locally on your machine. You can inspect and modify the
`Dockerfile` in order to check what is going on. For example, Dockerfile has three ARGs:

* image: base image (default: tensorflow/tensorflow)
* tag: to define tag for the Tensorflow Base image, e.g. '2.16.2' (default)

e.g.

```bash
$ cd ai4os-dev-env
$ docker build --build-arg tag=2.16.2-gpu -t ai4oshub/ai4os-dev-env:tf2.16.2 .
```

builds `ai4oshub/ai4os-dev-env:tf2.16.2` with GPU version of Tensorflow 2.16.2.


## Security & Authentication

### JupyterLab

When running locally without a password, JupyterLab displays a token in the terminal output. Copy this token to access the interface.

To set a custom password:

```bash
$ docker run -ti -p 8888:8888 -e idePASSWORD=my_secure_password ai4oshub/ai4os-dev-env
```

**Password requirements:**
- Minimum 8 characters
- Quoted if containing special characters: `-e idePASSWORD='my$ecret!'`

### VSCode (code-server)

⚠️ **Cloud Deployment**: Always set the `idePASSWORD` environment variable

```bash
$ docker run -p 8888:8888 -e idePASSWORD=my_secure_password ai4oshub/ai4os-dev-env deep-start -s
```

### Check Container Logs

To retrieve authentication tokens or debug issues:

```bash
$ docker logs <container-id>
```

<div align="center">
<img src="https://ai4eosc.eu/wp-content/uploads/sites/10/2022/09/horizontal-transparent.png" alt="logo" width="300"/>
</div>

# AI4OS Development Environment (AI4OSDev)

[![Build Status](https://jenkins.services.ai4os.eu/buildStatus/icon?job=AI4OS/ai4os-dev-env/main)](https://jenkins.services.ai4os.eu/job/AI4OS/job/ai4os-dev-env/job/main)
[![Contributor Covenant](https://img.shields.io/badge/Contributor%20Covenant-1.4-4baaaa.svg)](CODE_OF_CONDUCT.md)

This is a container that exposes Jupyter notebook and Jupyter Lab or VSCode together with the DEEP as a Service API component. There is **no application code** inside!

You can either mount host volume with the code into the container, or run jupyterlab terminal (e.g. http://127.0.0.1:8888/lab) to use git to pull your code and use either jupyter notebook or jupyter lab or vscode for the development of your application. Test it immediately and when ready, commit your changes back to your repository.


The resulting Docker image has pre-installed:
* Tensorflow or PyTorch or (just) Ubuntu
* [cookiecutter](https://github.com/cookiecutter/cookiecutter)
* git
* curl
* [deepaas](https://github.com/ai4os/DEEPaaS)
* [deep-start](https://github.com/ai4os/deep-start)
* [flaat](https://github.com/indigo-dc/flaat)
* jupyter, jupyterlab OR vscode ([code-server](https://github.com/coder/code-server))
* mc
* nano
* [oidc-agent](https://github.com/indigo-dc/oidc-agent)
* openssh-client
* python3
* pip3
* rclone
* wget


## Running the container

### Directly from Docker Hub

To run the Docker container directly from Docker Hub and start using jupyter notebook / jupyterlab or vscode run the following command:

```bash
$ docker run -ti -p 5000:5000 -p 6006:6006 -p 8888:8888 ai4oshub/ai4os-dev-env
```

This command will pull the Docker image from the Docker Hub and start the default command `deep-start -j´, which starts Jupyter Lab.

Then go either to http://127.0.0.1:8888/tree for jupyter notebook or to http://127.0.0.1:8888/lab for jupyterlab.

If you want to start DEEPaaS API service, go to the jupyterlab, i.e. http://127.0.0.1:8888/lab, open terminal, type:

```bash
$ deep-start
```

direct your browser to http://127.0.0.1:5000

Since Jan-2023, [deep-start](https://github.com/ai4os/deep-start) also allows to start VSCode ([code-server](https://github.com/coder/code-server)) via `deep-start -s´ :

```bash
$ docker run -ti -p 5000:5000 -p 6006:6006 -p 8888:8888 ai4oshub/ai4os-dev-env deep-start -s
```

If you need to mount some directories from your host into the container, please, use usual Docker way, e.g.

```bash
$ docker run -ti -p 5000:5000 -p 6006:6006 -p 8888:8888 -v $HOME/data:/srv/app/data ai4oshub/ai4os-dev-env
```

mounts your host directory `$HOME/data` into container's path `/srv/app/data`.

N.B. For either CPU-based or GPU-based images you can also use [udocker](https://github.com/indigo-dc/udocker) to run containers.

### Running via docker-compose

docker-compose.yml allows you to run the application with various configurations via docker-compose.

**N.B!** docker-compose.yml is of version '2.3', one needs docker 17.06.0+ and docker-compose ver.1.16.0+, see https://docs.docker.com/compose/install/

If you want to use Nvidia GPU (generic-gpu), you need nvidia-docker and docker-compose ver1.19.0+ , see [nvidia/FAQ](https://github.com/NVIDIA/nvidia-docker/wiki/Frequently-Asked-Questions#do-you-support-docker-compose)


### Building the container

If you want to build the container directly in your machine (because you want
to modify the `Dockerfile` for instance) follow the following instructions:

Building the container:

1. Get the `ai4os-dev-env` repository:

    ```bash
    $ git clone https://github.com/ai4os/ai4os-dev-env
    ```

2. Build the container (default is CPU and Python3 support):

    ```bash
    $ cd ai4os-dev-env
    $ docker build -t ai4oshub/ai4os-dev-env .
    ```

These two steps will download the repository from GitHub and will build the
Docker container locally on your machine. You can inspect and modify the
`Dockerfile` in order to check what is going on. For example, Dockerfile has three ARGs:

* image: base image (default: tensorflow/tensorflow)
* tag: to define tag for the Tensorflow Base image, e.g. '2.10.0' (default)

e.g.

```bash
$ cd ai4os-dev-env
$ docker build -t ai4oshub/ai4os-dev-env:tf2.10.0-cpu --build-arg tag=2.10.0 .
```

builds `ai4oshub/ai4os-dev-env:tf2.10.0-cpu` with CPU version of Tensorflow 2.10.0.


## Authenticating to Jupyter Notebook or Jupyterlab or VSCode

If you call http://127.0.0.1:8888/tree or http://127.0.0.1:8888/lab for the first time, you will get to "login" page. If you run the container locally, 
you will see in the terminal where the container started printed token to access Jupyter Notebook or Jupyter Lab. 
You can also see logs of your running container by envoking ```$ docker logs containerID```

One other way is to specify the jupyter password at the time of container instantiation:

```bash
$ docker run -ti -p 5000:5000 -p 6006:6006 -p 8888:8888 -e idePASSWORD=the_pass_for_ide ai4oshub/ai4os-dev-env
```

N.B. The quotes are treated as parts of the password. The password has to be more than 8 characters long!

DEEP-OC-generic-dev
============================================

![DEEP-Hybrid-DataCloud logo](https://docs.deep-hybrid-datacloud.eu/en/latest/_static/logo.png)

[![Build Status](https://jenkins.indigo-datacloud.eu:8080/buildStatus/icon?job=Pipeline-as-code/DEEP-OC-org/DEEP-OC-generic-dev/master)](https://jenkins.indigo-datacloud.eu:8080/job/Pipeline-as-code/job/DEEP-OC-org/job/DEEP-OC-generic-dev/job/master)

This is a container that exposes Jupyter noteboook and Jupyter Lab together with the DEEP as a Service API component. There is **no application code** inside!

You can either mount host volume with the code into the container, or as, there is git installed, run jupyterlab terminal (e.g. http://127.0.0.1:8888/lab) to pull your code and use either jupyter notebook or jupyter lab 
for the development of your application. Test it immediately and when ready, commit your changes back to your repository.


The resulting Docker image has pre-installed:
* Tensorflow 1.10
* git
* curl
* wget
* openssh-client
* python
* pip
* rclone
* flaat
* jupyter
* jupyterlab
* deepaas


# Running the container

## Directly from Docker Hub

To run the Docker container directly from Docker Hub and start using jupyter notebook or jupyterlab run the following command:

```bash
$ docker run -ti -p 5000:5000 -p 8888:8888 deephdc/deep-oc-generic-dev
```

This command will pull the Docker image from the Docker Hub.

Then go either to http://127.0.0.1:8888/tree for jupyter notebook or to http://127.0.0.1:8888/lab for jupyterlab.

If you want to start DEEPaaS API service, go to the jupyterlab, i.e. http://127.0.0.1:8888/lab, open terminal, type:

```bash
$ deepaas-run --listen-ip=0.0.0.0
```

direct your browser to http://127.0.0.1:5000

If you need to mount some directories from your host into the container, please, use usual Docker way, e.g.

```bash
$ docker run -ti -p 5000:5000 -p 8888:8888 -v $HOME/data:/srv/app/data deephdc/deep-oc-generic-dev
```

mounts your host directory $HOME/data into containers path /srv/app/data


## docker-compose

docker-compose.yml allows you to run the application with various configurations via docker-compose.

**N.B!** docker-compose.yml is of version '2.3', one needs docker 17.06.0+ and docker-compose ver.1.16.0+, see https://docs.docker.com/compose/install/

If you want to use Nvidia GPU (generic-gpu), you need nvidia-docker and docker-compose ver1.19.0+ , see [nvidia/FAQ](https://github.com/NVIDIA/nvidia-docker/wiki/Frequently-Asked-Questions#do-you-support-docker-compose)


## Authenticating to Jupyter Notebook or Jupyterlab

If you call http://127.0.0.1:8888/tree or http://127.0.0.1:8888/lab for the first time, you will get to "login" page. If you run the container locally, 
you will see in the terminal where the container started printed token to access Jupyter Notebook or Jupyter Lab. 
You can also see logs of your running container by envoking ```$ docker logs containerID```

One other way is to specify the jupyter password at the time of container instantiation:

```bash
$ docker run -ti -p 5000:5000 -p 8888:8888 -e jupyterPASSWORD=the_pass_for_jupyter deephdc/deep-oc-generic-dev
```

N.B. The quotes are treated as parts of the password. The password has to be more than 8 characters long.


## Building the container

If you want to build the container directly in your machine (because you want
to modify the `Dockerfile` for instance) follow the following instructions:

Building the container:

1. Get the `DEEP-OC-generic-dev` repository (this repo):

    ```bash
    $ git clone https://github.com/deephdc/DEEP-OC-generic-dev
    ```

2. Build the container (default with GPU and Python3 support):

    ```bash
    $ cd DEEP-OC-generic-dev
    $ docker build -t deephdc/deep-oc-generic-dev .
    ```

These two steps will download the repository from GitHub and will build the
Docker container locally on your machine. You can inspect and modify the
`Dockerfile` in order to check what is going on. For example, Dockerfile has two ARGs:

tag: to define tag for the Tensorflow Baseimage, e.g. '1.10.0-gpu-py3' (default)
pyVer: to specify python version as 'python' (for python2) or 'python3' (for python3)

e.g.

```bash
$ cd DEEP-OC-generic-dev
$ docker build -t deephdc/deep-oc-generic-dev:cpu-py2 --build-arg tag=1.10.0 --build-arg pyVer=python .
```

builds deephdc/deep-oc-generic-dev:cpu-py2 with CPU version of Tensorflow 1.10.0 and python2.

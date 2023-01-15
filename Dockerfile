# Dockerfile has following arguments: image, tag, and orchentVer
# image - base image (default: tensorflow/tensorflow)
# tag - tag for Tensorflow Image (default: 2.10.0)
# orchentVer - version of orchent (see https://github.com/indigo-dc/orchent/releases/)
# If you need to change default values, during the build do:
# docker build -t deephdc/deep-oc-generic-dev --build-arg tag=XX

ARG image=tensorflow/tensorflow
ARG tag=2.10.0
# Base image, e.g. tensorflow/tensorflow:1.7.0
FROM ${image}:${tag}

LABEL maintainer='V.Kozlov (KIT)'
# Generic container for Development
# Includes Jupyter Notebook, Jupyter Lab, DEEPaaS API

# orchent version
ARG orchentVer=1.2.9

# Oneclient version, has to match OneData Provider and Linux version
ARG oneclient_ver=20.02.19-1~focal

# Install ubuntu updates and python related stuff
# link python3 to python, pip3 to pip, if needed
RUN DEBIAN_FRONTEND=noninteractive apt-get update && \
    apt-get install -y --no-install-recommends \
        gnupg \
        lsb-release \
        curl \
        software-properties-common && \
    #apt-key adv --keyserver hkp://pgp.surfnet.nl \
    #--recv-keys ACDFB08FDC962044D87FF00B512839863D487A87 && \
    curl repo.data.kit.edu/key.pgp | apt-key add - && \
    add-apt-repository "deb http://repo.data.kit.edu/ubuntu/$(lsb_release -sr) ./" && \
    DEBIAN_FRONTEND=noninteractive apt-get update && \
    apt-get install -y --no-install-recommends \
         git \
         jq \
         mc \
         nano \
         openssh-client \
         oidc-agent \
         wget \
         psmisc \
         python3-setuptools \
         python3-pip \
         python3-dev \
         python3-wheel && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /root/.cache/pip/* && \
    rm -rf /tmp/* && \
    python --version && \
    pip --version


# Set LANG environment
ENV LANG C.UTF-8

# Set the working directory
WORKDIR /srv

# bashrc entries for oidc-agent
COPY oidc-agent/oidc-check.bashrc /root/

# Install orchent, oidc-agent, and rclone
RUN wget https://github.com/indigo-dc/orchent/releases/download/v${orchentVer}/orchent_${orchentVer}_amd64.deb && \
    dpkg -i orchent_${orchentVer}_amd64.deb && \
    wget https://downloads.rclone.org/rclone-current-linux-amd64.deb && \
    dpkg -i rclone-current-linux-amd64.deb && \
    apt-get install -f && \   
    rm orchent_${orchentVer}_amd64.deb \
       rclone-current-linux-amd64.deb && \
    cat /root/oidc-check.bashrc >> /root/.bashrc && \
    mkdir /srv/.oidc-agent && \
    mkdir /srv/.rclone/ && touch /srv/.rclone/rclone.conf && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /root/.cache/pip/* && \
    rm -rf /tmp/*

# Environment settings for orchent, oidc-agent, rclone
## CNAF instance is depricated? 2023
#ENV ORCHENT_CNAF https://paas.cloud.cnaf.infn.it/orchestrator
##
#ENV ORCHENT_BARI https://deep-paas.cloud.ba.infn.it/orchestrator
ENV ORCHENT_URL https://deep-paas.cloud.ba.infn.it/orchestrator
ENV ORCHENT_AGENT_ACCOUNT deep-iam
ENV OIDC_CONFIG_DIR /srv/.oidc-agent
ENV RCLONE_CONFIG /srv/.rclone/rclone.conf

# For compatibility with udocker
ENV USER root
ENV HOME /root

# INSTALL oneclient for ONEDATA
RUN curl -sS  http://get.onedata.org/oneclient.sh  | bash -s -- oneclient="$oneclient_ver" && \
    apt-get clean && \
    mkdir -p /mnt/onedata && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /tmp/*

# Install:
# cookiecutter (tool to create projects from project templates)
# DEEPaaS API  (a REST API for providing access to machine learning models)
# FLAAT        (FLAsk support for handling Access Tokens)
# JupyterLab   (see https://jupyterlab.readthedocs.io )
RUN pip install --no-cache-dir \
    cookiecutter \
    'deepaas>=1.3.0' \
    flaat \
    jupyterlab && \
    rm -rf /root/.cache/pip/* && \
    rm -rf /tmp/*

# Disable FLAAT authentication by default
ENV DISABLE_AUTHENTICATION_AND_ASSUME_AUTHENTICATED_USER yes

# JupyterLab environment settings
ENV JUPYTER_CONFIG_DIR /srv/.deep-start/
ENV SHELL /bin/bash

# Install deep-start script
# N.B.: This repository also contains run_jupyter.sh
# For compatibility, create symlink /srv/.jupyter/run_jupyter.sh
RUN git clone https://github.com/deephdc/deep-start /srv/.deep-start && \
    ln -s /srv/.deep-start/deep-start.sh /usr/local/bin/deep-start && \
    ln -s /srv/.deep-start/run_jupyter.sh /usr/local/bin/run_jupyter && \
    mkdir -p /srv/.jupyter && \
    ln -s /srv/.deep-start/run_jupyter.sh /srv/.jupyter/run_jupyter.sh

COPY INFO.md /srv
COPY lab/deep-workspace.json /srv/.deep-start/lab
RUN jupyter lab workspaces import /srv/.deep-start/lab/deep-workspace.json

# Open DEEPaaS port
EXPOSE 5000

# Open Monitoring port
EXPOSE 6006

# Open JupyterLab port
EXPOSE 8888

# Run Jupyter Lab
CMD ["run_jupyter", "--allow-root"]

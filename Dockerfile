# Dockerfile has following arguments: image, tag, pyVer, and orchentVer
# image - base image (default: tensorflow/tensorflow)
# tag - tag for Tensorflow Image (default: 1.10-py3)
# pyVer - python versions as 'python' or 'python3' (default: python3)
# orchentVer - version of orchent (see https://github.com/indigo-dc/orchent/releases/)
# Do not forget that 'tag' and 'pyVer' in case of Tensorflow are dependent!
# If you need to change default values, during the build do:
# docker build -t deephdc/deep-oc-generic-dev --build-arg tag=XX --build-arg pyVer=python

ARG image=tensorflow/tensorflow
ARG tag=1.14.0-py3
# Base image, e.g. tensorflow/tensorflow:1.7.0
FROM ${image}:${tag}

LABEL maintainer='V.Kozlov (KIT)'
# Generic container for Development
# Includes Jupyter Notebook, Jupyter Lab, DEEPaaS API

# python version
ARG pyVer=python3

# orchent version
ARG orchentVer=1.2.5

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
         mc \
         nano \
         openssh-client \
         oidc-agent \
         wget \
         $pyVer-setuptools \
         $pyVer-pip \
         $pyVer-dev \
         $pyVer-wheel && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /root/.cache/pip/* && \
    rm -rf /tmp/* && \
    if [ "$pyVer" = "python3" ] ; then \
       if [ ! -e /usr/bin/pip ]; then \
          ln -s /usr/bin/pip3 /usr/bin/pip; \
       fi; \
       if [ ! -e /usr/bin/python ]; then \
          ln -s /usr/bin/python3 /usr/bin/python; \
       fi; \
    fi && \
    python --version && \
    pip --version


# Set LANG environment
ENV LANG C.UTF-8

# Set the working directory
WORKDIR /srv

# bashrc entries for oidc-agent
COPY oidc-agent/oidc-check.bashrc /root/

# Install orchent, oidc-agent, and rclone
RUN wget https://github.com/indigo-dc/orchent/releases/download/${orchentVer}/orchent_${orchentVer}_amd64.deb && \
    dpkg -i orchent_${orchentVer}_amd64.deb && \
    wget https://downloads.rclone.org/rclone-current-linux-amd64.deb && \
    dpkg -i rclone-current-linux-amd64.deb && \
    apt install -f && \   
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
ENV ORCHENT_BARI https://deep-paas.cloud.ba.infn.it/orchestrator
ENV ORCHENT_CNAF https://paas.cloud.cnaf.infn.it/orchestrator
ENV ORCHENT_URL $ORCHENT_CNAF
ENV ORCHENT_AGENT_ACCOUNT deep-iam
ENV OIDC_CONFIG_DIR /srv/.oidc-agent
ENV RCLONE_CONFIG /srv/.rclone/rclone.conf

# For compatibility with udocker
ENV USER root
ENV HOME /root

# INSTALL oneclient for ONEDATA
RUN curl -sS  http://get.onedata.org/oneclient-1902.sh | bash && \
    apt-get clean && \
    mkdir -p /mnt/onedata && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /tmp/*

# Install:
# cookiecutter (tool to create projects from project templates)
# DEEPaaS API  (a REST API for providing access to machine learning models)
# FLAAT        (FLAsk support for handling Access Tokens)
# JupyterLab
RUN pip install --no-cache-dir \
    cookiecutter \
    'deepaas>=1.0.1' \
    flaat \
    jupyterlab && \
    rm -rf /root/.cache/pip/* && \
    rm -rf /tmp/*

# Disable FLAAT authentication by default
ENV DISABLE_AUTHENTICATION_AND_ASSUME_AUTHENTICATED_USER yes

# JupyterLab environment settings
ENV JUPYTER_CONFIG_DIR /srv/.deep-start/
ENV SHELL /bin/bash

# EXPERIMENTAL: install deep-start script
# N.B.: This repository also contains run_jupyter.sh
RUN git clone https://github.com/deephdc/deep-start /srv/.deep-start && \
    ln -s /srv/.deep-start/deep-start.sh /usr/local/bin/deep-start && \
    ln -s /srv/.deep-start/run_jupyter.sh /usr/local/bin/run_jupyter

# Open DEEPaaS port
EXPOSE 5000

# Open Monitoring port
EXPOSE 6006

# Open JupyterLab port
EXPOSE 8888

# Run Jupyter Lab
CMD ["run_jupyter", "--allow-root"]

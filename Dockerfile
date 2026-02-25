# Dockerfile has following arguments: image, tag, and orchentVer 
# image - base image (default: tensorflow/tensorflow)
# tag - tag for Tensorflow Image (default: 2.10.0)
# orchentVer - version of orchent (see https://github.com/indigo-dc/orchent/releases/)
# If you need to change default values, during the build do:
# docker build -t ai4oshub/ai4os-dev-env --build-arg tag=XX .

ARG image=tensorflow/tensorflow
ARG tag=2.10.0
# Base image, e.g. tensorflow/tensorflow:2.10.0
FROM ${image}:${tag}

LABEL maintainer='V.Kozlov (KIT)'
# Generic container for Development
# Includes Jupyter Notebook, Jupyter Lab, DEEPaaS API

# orchent version
ARG orchentVer=1.2.9

# Install ubuntu updates, python3 related stuff, some tools
# gcc is needed in Pytorch images because deepaas installation might break otherwise (see docs) 
# (gcc is already installed in tensorflow images)
ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        curl \
        gnupg \
        git \
        gcc \
        jq \
        lsb-release \
        mc \
        nano \
        openssh-client \
        wget \
        psmisc \
        python3-setuptools \
        python3-pip \
        python3-dev \
        python3-wheel \
        software-properties-common && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /tmp/* && \
    python3 --version && \
    pip3 --version

# Set LANG environment
ENV LANG C.UTF-8

# Set the working directory
WORKDIR /srv

# install oidc-agent
RUN curl repo.data.kit.edu/repo-data-kit-edu-key.gpg | gpg --dearmor > /etc/apt/trusted.gpg.d/kitrepo-archive.gpg && \
    #add-apt-repository "deb http://repo.data.kit.edu/ubuntu/$(lsb_release -sr) ./"
    #add-apt-repository is broken in tensorflow/tensorflow:2.14.0, use manually adding to sources.list
    echo "deb https://repo.data.kit.edu//ubuntu/$(lsb_release -sr) ./" | tee -a /etc/apt/sources.list && \
    DEBIAN_FRONTEND=noninteractive apt-get update && \
    apt-get install -y --no-install-recommends oidc-agent-cli && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# bashrc entries for oidc-agent
COPY oidc-agent/oidc-check.bashrc /root/
RUN cat /root/oidc-check.bashrc >> /root/.bashrc && mkdir /srv/.oidc-agent

# Install orchent and rclone
RUN wget https://github.com/indigo-dc/orchent/releases/download/v${orchentVer}/orchent_${orchentVer}_amd64.deb && \
    dpkg -i orchent_${orchentVer}_amd64.deb && \
    wget https://downloads.rclone.org/rclone-current-linux-amd64.deb && \
    dpkg -i rclone-current-linux-amd64.deb && \
    apt-get install -f && \   
    rm orchent_${orchentVer}_amd64.deb \
       rclone-current-linux-amd64.deb && \
    mkdir /srv/.rclone/ && touch /srv/.rclone/rclone.conf && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
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
# Usually oneclient version has to match OneData Provider and Linux version
# here we let oneclient.sh install script to decide
RUN curl -sS  http://get.onedata.org/oneclient.sh | bash && \
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
RUN git clone --depth 1 https://github.com/deephdc/deep-start /srv/.deep-start && \
    ln -s /srv/.deep-start/deep-start.sh /usr/local/bin/deep-start

COPY INFO.md /srv
COPY lab/deep-workspace.json /srv/.deep-start/lab
RUN jupyter lab workspaces import /srv/.deep-start/lab/deep-workspace.json

# Open DEEPaaS port
EXPOSE 5000

# Open Monitoring port
EXPOSE 6006

# Open JupyterLab port
EXPOSE 8888

# Copy entrypoint to update INFO.md from remote URL
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

# By default run Jupyter Lab
CMD ["deep-start", "-j"]

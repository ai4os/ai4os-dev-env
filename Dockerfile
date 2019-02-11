# Dockerfile has two Arguments: tag and pyVer
# tag - tag for Tensorflow Image (default: 1.10-gpu-py3)
# pyVer - python versions as 'python' or 'python3' (default: python3)
# Do not forget that 'tag' and 'pyVer' in case of Tensorflow are dependent!
# If you need to change default values, during the build do:
# docker build -t deephdc/deep-oc-generic-dev --build-arg tag=XX --build-arg pyVer=python

ARG tag=1.10.0-gpu-py3
# Base image, e.g. tensorflow/tensorflow:1.7.0
FROM tensorflow/tensorflow:${tag}

LABEL maintainer='V.Kozlov (KIT)'
# Generic container for Development
# Includes Jupyter Notebook, Jupyter Lab, DEEPaaS API

ARG pyVer=python3
# Install updates, some packages + python related stuff
RUN DEBIAN_FRONTEND=noninteractive apt-get update && \
    apt-get install -y --no-install-recommends \
         git \
         curl \
         wget \
         openssh-client \
         mc \
         libcurl3 \
         libmicrohttpd10 \
         $pyVer-setuptools \
         $pyVer-pip \
         $pyVer-wheel && \ 
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /root/.cache/pip/* && \
    rm -rf /tmp/*


# Set LANG environment
ENV LANG C.UTF-8

# Set the working directory
WORKDIR /srv

COPY oidc-agent/oidc-check.bashrc /root/

# install orchent, oidc-agent, and rclone
RUN release=$(lsb_release -cs) && \
    wget https://github.com/indigo-dc/oidc-agent/releases/download/v2.2.2/$release-liboidc-agent2_2.2.2_amd64.deb && \
    dpkg -i $release-liboidc-agent2_2.2.2_amd64.deb && \
    apt install -f && \
    wget https://github.com/indigo-dc/oidc-agent/releases/download/v2.2.2/$release-oidc-agent_2.2.2_amd64.deb && \
    dpkg -i $release-oidc-agent_2.2.2_amd64.deb && \
    cat /root/oidc-check.bashrc >> /root/.bashrc && \
    wget https://github.com/indigo-dc/orchent/releases/download/1.2.2/orchent-1.2.2-amd64.deb && \
    dpkg -i orchent-1.2.2-amd64.deb && \
    wget https://downloads.rclone.org/rclone-current-linux-amd64.deb && \
    dpkg -i rclone-current-linux-amd64.deb && \
    apt install -f && \
    mkdir /srv/.rclone/ && touch /srv/.rclone/rclone.conf && \   
    rm $release-liboidc-agent2_2.2.2_amd64.deb \
       $release-oidc-agent_2.2.2_amd64.deb \
       orchent-1.2.2-amd64.deb \
       rclone-current-linux-amd64.deb && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /root/.cache/pip/* && \
    rm -rf /tmp/*

ENV USER root
ENV ORCHENT_BARI https://deep-paas.cloud.ba.infn.it/orchestrator
ENV ORCHENT_CNAF https://paas.cloud.cnaf.infn.it/orchestrator
ENV ORCHENT_URL $ORCHENT_CNAF
ENV ORCHENT_AGENT_ACCOUNT deep-iam
ENV RCLONE_CONFIG /srv/.rclone/rclone.conf


# Install DEEPaaS from PyPi
# Install FLAAT (FLAsk support for handling Access Tokens)
# Install Jupyter Notebook and Jupyter Lab
RUN pip install --no-cache-dir \
        deepaas \
        flaat \
        jupyterlab && \
    rm -rf /root/.cache/pip/* && \
    rm -rf /tmp/*

# Disable FLAAT authentication by default
ENV DISABLE_AUTHENTICATION_AND_ASSUME_AUTHENTICATED_USER yes

ENV JUPYTER_CONFIG_DIR /srv/.jupyter/
COPY jupyter/jupyter_notebook_config.py /srv/.jupyter/
COPY jupyter/run_jupyter.sh /
#COPY jupyter/jupyterSSL.pem /srv/.jupyter/
#COPY jupyter/jupyterSSL.key /srv/.jupyter/
# Necessary for the Jupyter Lab terminal
ENV SHELL /bin/bash


# Open DEEPaaS port
EXPOSE 5000

# Open Jupyter port
# REMINDER: Tensorflow Docker Images already EXPOSE ports 6006 and 8888
EXPOSE 8888

CMD ["/run_jupyter.sh","--allow-root"]

# Dockerfile has two Arguments: tag and pyVer
# tag - tag for Tensorflow Image (default: 1.10-gpu-py3)
# pyVer - python versions as 'python' or 'python3' (default: python3)
# Do not forget that 'tag' and 'pyVer' in case of Tensorflow are dependent!
# If you need to change default values, during the build do:
# docker build -t deephdc/deep-oc-generic-dev --build-arg tag=XX --build-arg pyVer=python

ARG tag=1.10-gpu-py3
# Base image, e.g. tensorflow/tensorflow:1.7.0
FROM tensorflow/tensorflow:${tag}

LABEL maintainer='V.Kozlov (KIT)'
# Generic container for Development
# Includes Jupyter Notebook, Jupyter Lab, DEEPaaS API

ARG pyVer=python3
# Install ubuntu updates and python related stuff
RUN DEBIAN_FRONTEND=noninteractive apt-get update && \
    apt-get install -y --no-install-recommends \
         git \
         curl \
         wget \
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

# install rclone
RUN wget https://downloads.rclone.org/rclone-current-linux-amd64.deb && \
    dpkg -i rclone-current-linux-amd64.deb && \
    apt install -f && \
    touch /srv/.rclone.conf && \
    rm rclone-current-linux-amd64.deb && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /root/.cache/pip/* && \
    rm -rf /tmp/*

# Install DEEPaaS from PyPi
# Install FLAAT (FLAsk support for handling Access Tokens)
# Install Jupyter Notebook and Jupyter Lab
RUN pip install --no-cache-dir \
        deepaas \
        flaat \
        jupyter \
        jupyterlab && \
    $pyVer -m ipykernel.kernelspec && \
    rm -rf /root/.cache/pip/* && \
    rm -rf /tmp/*

# Disable FLAAT authentication by default
ENV DISABLE_AUTHENTICATION_AND_ASSUME_AUTHENTICATED_USER yes

COPY jupyter/jupyter_notebook_config.py /root/.jupyter/
COPY jupyter/run_jupyter.sh /
# Necessary for the Jupyter Lab terminal
ENV SHELL /bin/bash

# Open DEEPaaS port
EXPOSE 5000

# Open Jupyter port
# REMINDER: Tensorflow Docker Images already EXPOSE ports 6006 and 8888
EXPOSE 8888

CMD ["/run_jupyter.sh","--allow-root"]

# Dockerfile has three Arguments: image, tag, and pyVer
# image - base image (default: tensorflow/tensorflow)
# tag - tag for Tensorflow Image (default: 1.10-py3)
# pyVer - python versions as 'python' or 'python3' (default: python3)
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

# If to install JupyterLab
ARG jlab=true

# Install ubuntu updates and python related stuff
# link python3 to python, pip3 to pip, if needed
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

# Install rclone
RUN wget https://downloads.rclone.org/rclone-current-linux-amd64.deb && \
    dpkg -i rclone-current-linux-amd64.deb && \
    apt install -f && \
    mkdir /srv/.rclone/ && touch /srv/.rclone/rclone.conf && \
    rm rclone-current-linux-amd64.deb && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /root/.cache/pip/* && \
    rm -rf /tmp/*

# Install DEEPaaS from PyPi
RUN pip install --no-cache-dir deepaas && \
    rm -rf /root/.cache/pip/* && \
    rm -rf /tmp/*

# Install FLAAT (FLAsk support for handling Access Tokens)
RUN pip install --no-cache-dir flaat && \
    rm -rf /root/.cache/pip/* && \
    rm -rf /tmp/*

# Disable FLAAT authentication by default
ENV DISABLE_AUTHENTICATION_AND_ASSUME_AUTHENTICATED_USER yes

# Install DEEP debug_log scripts:
RUN git clone https://github.com/deephdc/deep-debug_log /srv/.debug_log

# Install JupyterLab
ENV JUPYTER_CONFIG_DIR /srv/.jupyter/
ENV SHELL /bin/bash
RUN if [ "$jlab" = true ]; then \
       pip install --no-cache-dir jupyterlab ; \
       git clone https://github.com/deephdc/deep-jupyter /srv/.jupyter ; \
    else echo "[INFO] Skip JupyterLab installation!"; fi

# Open DEEPaaS port
EXPOSE 5000

# Open Monitoring port
EXPOSE 6006

# Open JupyterLab port
EXPOSE 8888

# Run Jupyter Lab
CMD ["/srv/.jupyter/run_jupyter.sh", "--allow-root"]

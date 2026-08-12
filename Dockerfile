# =============================================================================
# AI4OS Development Environment
# =============================================================================
# A containerized development environment for AI/ML workloads on AI4EOSC-like platforms
# Provides JupyterLab, VSCode, DEEPaaS API, and cloud storage integration
#
# Build arguments:
#   image       - Base image (default: tensorflow/tensorflow)
#   tag         - Base image tag (default: 2.16.2)
#
# Examples:
#   docker build -t ai4oshub/ai4os-dev-env .
#   docker build --build-arg tag=2.16.2-gpu -t ai4oshub/ai4os-dev-env:tf2.16.2 .
#   docker build --build-arg image=pytorch/pytorch --build-arg tag=2.3.0-cuda11.8-cudnn8-runtime .
# =============================================================================

ARG image=tensorflow/tensorflow
ARG tag=2.16.2
FROM ${image}:${tag}

LABEL maintainer="V.Kozlov (KIT)"
LABEL org.opencontainers.image.title="AI4OS Development Environment"
LABEL org.opencontainers.image.description="Containerized AI/ML development environment for AI4EOSC"
LABEL org.opencontainers.image.source="https://github.com/ai4os/ai4os-dev-env"
LABEL org.opencontainers.image.licenses="Apache-2.0"

# -----------------------------------------------------------------------------
# Build Arguments
# -----------------------------------------------------------------------------
ARG DEBIAN_FRONTEND=noninteractive

# -----------------------------------------------------------------------------
# System Dependencies
# -----------------------------------------------------------------------------
RUN apt-get update && \
    # Core development tools
    apt-get install -y --no-install-recommends \
        build-essential \
        curl \
        git \
        git-lfs \
        gnupg \
        jq \
        lsb-release \
        openssh-client \
        psmisc \
        software-properties-common \
        wget \
    # File management & editors
        mc \
        nano \
    # Archive tools
        unzip \
        zip \
        bzip2 \
    # Monitoring & debugging
        ca-certificates \
        htop \
        iputils-ping \
        net-tools \
    # Python development
        python3-dev \
        python3-pip \
        python3-setuptools \
        python3-wheel \
    # Cleanup
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
    # Verify installations
    && python3 --version \
    && pip3 --version \
    && git --version

# -----------------------------------------------------------------------------
# Environment Configuration
# -----------------------------------------------------------------------------
ENV LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    USER=root \
    HOME=/root

WORKDIR /srv

# -----------------------------------------------------------------------------
# OIDC Agent
# -----------------------------------------------------------------------------
RUN curl -sSL repo.data.kit.edu/repo-data-kit-edu-key.gpg | gpg --dearmor -o /etc/apt/trusted.gpg.d/kitrepo-archive.gpg && \
    echo "deb https://repo.data.kit.edu/ubuntu/$(lsb_release -sr) ./" >> /etc/apt/sources.list && \
    apt-get update && \
    apt-get install -y --no-install-recommends oidc-agent-cli && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

COPY oidc-agent/oidc-check.bashrc /root/
RUN cat /root/oidc-check.bashrc >> /root/.bashrc && \
    mkdir -p /srv/.oidc-agent

ENV OIDC_CONFIG_DIR=/srv/.oidc-agent

# -----------------------------------------------------------------------------
# Rclone (Cloud Storage Sync - supports S3, Nextcloud, Google Drive, etc.)
# -----------------------------------------------------------------------------
RUN wget -q https://downloads.rclone.org/rclone-current-linux-amd64.deb && \
    dpkg -i rclone-current-linux-amd64.deb && \
    apt-get install -f -y && \
    rm -f rclone-current-linux-amd64.deb && \
    mkdir -p /srv/.rclone && touch /srv/.rclone/rclone.conf && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/*

ENV RCLONE_CONFIG=/srv/.rclone/rclone.conf

# -----------------------------------------------------------------------------
# OneClient for Onedata
# -----------------------------------------------------------------------------
# Usually oneclient version has to match OneData Provider and the Linux version.
# Here we let oneclient.sh installation script to decide
RUN curl -sS http://get.onedata.org/oneclient.sh | bash && \
    apt-get clean && \
    mkdir -p /mnt/onedata && \
    rm -rf /var/lib/apt/lists/* /tmp/*

# -----------------------------------------------------------------------------
# Python Packages (AI4OS Stack)
# -----------------------------------------------------------------------------
RUN pip install --no-cache-dir \
    cookiecutter \
    'deepaas>=2.1.0' \
    flaat \
    jupyterlab \
    && rm -rf /root/.cache/pip/*

ENV DISABLE_AUTHENTICATION_AND_ASSUME_AUTHENTICATED_USER=yes

# -----------------------------------------------------------------------------
# deep-start Launcher
# -----------------------------------------------------------------------------
RUN git clone --depth 1 https://github.com/deephdc/deep-start /srv/.deep-start && \
    ln -s /srv/.deep-start/deep-start.sh /usr/local/bin/deep-start

# -----------------------------------------------------------------------------
# JupyterLab Configuration
# -----------------------------------------------------------------------------
ENV JUPYTER_CONFIG_DIR=/srv/.deep-start/ \
    SHELL=/bin/bash

COPY INFO.md /srv
COPY lab/deep-workspace.json /srv/.deep-start/lab/
RUN jupyter lab workspaces import /srv/.deep-start/lab/deep-workspace.json

# -----------------------------------------------------------------------------
# VSCode (code-server) - Pre-installed with GLIBC Compatibility
# -----------------------------------------------------------------------------
# Install code-server at build time to avoid runtime installation delay
# Uses v4.16.1 for GLIBC < 2.28, latest for newer systems
# NOTE: PASSWORD environment variable MUST be set at runtime for cloud deployment
RUN set -eux; \
    GLIBC_VERSION=$(ldd --version | awk '/ldd/{print $NF}'); \
    echo "[INFO] Detected GLIBC version: $GLIBC_VERSION"; \
    if [ "$(echo "$GLIBC_VERSION" | awk -F. '{printf("%d%03d%03d\n", $1,$2,$3)}')" -ge 2028000 ]; then \
        echo "[INFO] GLIBC >= 2.28, installing latest code-server"; \
        curl -fsSL https://code-server.dev/install.sh | sh; \
    else \
        echo "[INFO] GLIBC < 2.28, installing code-server v4.16.1 for compatibility"; \
        curl -fsSL https://code-server.dev/install.sh | sh -s -- --version 4.16.1; \
    fi && \
    # Clean up downloaded .deb installer files (~250MB)
    find / -maxdepth 3 -name "code-server*.deb" -delete 2>/dev/null || true && \
    rm -rf ${HOME}/.cache/code-server /tmp/* && \
    mkdir -p /srv/.deep-start/vscode/code-server

# -----------------------------------------------------------------------------
# OpenCode AI Assistant
# -----------------------------------------------------------------------------
# Terminal-based AI coding agent for interactive development
# See: https://opencode.ai/docs#install
# Binary installed to: $HOME/.opencode/bin/opencode (~200-300MB)
RUN curl -fsSL https://opencode.ai/install | bash && \
    # ln -s $HOME/.opencode/bin/opencode /usr/local/bin/opencode && \
    # Clean any temporary files (install script auto-cleans, but ensure completeness)
    rm -rf /tmp/*

# -----------------------------------------------------------------------------
# Ports & Entrypoint
# -----------------------------------------------------------------------------
# DEEPaaS API
EXPOSE 5000
# Monitoring (TensorBoard)
EXPOSE 6006
# JupyterLab
EXPOSE 8888

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

CMD ["deep-start", "-j"]

# -----------------------------------------------------------------------------
# Health Check
# -----------------------------------------------------------------------------
# Generic check - works for both JupyterLab and VSCode on port 8888
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8888/ || exit 1

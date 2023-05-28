FROM arm64v8/ubuntu:20.04
ARG APP_ENV

ENV APP_ENV=${APP_ENV} \
    PYTHONFAULTHANDLER=1 \
    PYTHONUNBUFFERED=1 \
    PYTHONHASHSEED=random \
    PIP_DISABLE_PIP_VERSION_CHECK=on \
    PIP_DEFAULT_TIMEOUT=100 \
    POETRY_VERSION=1.4.1 \
    DEBIAN_FRONTEND=noninteractive \
    AGENT_TOOLSDIRECTORY=/opt/hostedtoolcache \
    GIT_LFS_VERSION="3.2.0" \
    LANG=en_US.UTF-8 \
    LANGUAGE=en_US.UTF-8 

RUN mkdir -p $AGENT_TOOLSDIRECTORY

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Install base dependencies
RUN set -xe \
    && apt-get update \
    && apt-get upgrade -y \
    && apt-get install git unzip lsb-release wget curl jq build-essential ca-certificates python3.9 python3-pip dumb-init \
    libssl-dev libffi-dev openssh-client tar apt-transport-https sudo gpg-agent software-properties-common zstd gettext libcurl4-openssl-dev jq \
    gnupg zip locales --no-install-recommends -y \
    && curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add - \
    && sudo add-apt-repository "deb [arch=arm64] https://download.docker.com/linux/ubuntu focal stable" \
    && apt-cache policy docker-ce \
    && apt-get install -y docker-ce docker-ce-cli docker-buildx-plugin containerd.io docker-compose-plugin --no-install-recommends --allow-unauthenticated \
    && groupadd -g 121 runner \
    && useradd -mr -d /home/runner -u 1001 -g 121 runner \
    && usermod -aG sudo runner \
    && usermod -aG docker runner \
    && echo '%sudo ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers

# Install Poetry
RUN set -xe \
    && pip install "poetry==$POETRY_VERSION"

WORKDIR /build

# Install NodeJS
RUN set -xe \
    && curl -fsSL https://deb.nodesource.com/setup_18.x | bash - && apt-get install -y nodejs

# Install Terraform 
RUN set -xe \
    && wget https://releases.hashicorp.com/terraform/1.3.2/terraform_1.3.2_linux_arm.zip \
    && unzip terraform_1.3.2_linux_amd64.zip \
    && chmod +x terraform \
    && mv terraform /usr/bin/ \
    && npm i -g cdktf-cli@0.15.2

# Install AWS CLI
RUN set -xe \
    && curl "https://awscli.amazonaws.com/awscli-exe-linux-aarch64.zip" -o "awscliv2.zip" \
    && unzip awscliv2.zip \
    && chmod +x ./aws/install \
    && ./aws/install 


COPY start.sh /start.sh
RUN chmod +x /start.sh

WORKDIR /home/runner

# Clean up
RUN set -xe \ 
    && apt-get clean autoclean \
    && apt-get autoremove -y \
    && rm -rf /var/lib/{apt,dpkg,cache,log}/ /build  \
    && chown -R runner:runner /home/runner/ /opt/hostedtoolcache




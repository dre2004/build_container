FROM python:3.10-slim-bullseye

ARG RUNNER_VERSION="2.303.0"

# Install base dependencies
RUN set -xe && \
    apt-get update && apt-get install git unzip wget curl jq build-essential \
    libssl-dev libffi-dev --no-install-recommends -y


# Install Github Runner dependencies
RUN set -xe && \
    mkdir /actions-runner && cd actions-runner && \
    curl -O -L https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz && \
    tar xzf ./actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz && \
    rm actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz && \
    pwd && ls -lah && \
    /actions-runner/bin/installdependencies.sh


WORKDIR /build

# Install NodeJS
RUN set -xe && \
    curl -fsSL https://deb.nodesource.com/setup_18.x | bash - && apt-get install -y nodejs

# Install Terraform 
RUN set -xe && \
    wget https://releases.hashicorp.com/terraform/1.3.2/terraform_1.3.2_linux_amd64.zip && \
    unzip terraform_1.3.2_linux_amd64.zip && \
    chmod +x terraform && \
    mv terraform /usr/bin/ && \
    rm terraform_1.3.2_linux_amd64.zip

# Install AWS CLI
RUN set -xe && \
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && \
    unzip awscliv2.zip && \
    chmod +x ./aws/install && \
    ./aws/install && \
    rm awscliv2.zip

# Clean up
RUN set -xe && \
    rm -rf /build && \
    apt-get clean autoclean && apt-get autoremove -y && \
    rm -rf /var/lib/{apt,dpkg,cache,log}/

WORKDIR /
COPY start.sh start.sh
RUN chmod +x start.sh

ENTRYPOINT ["./start.sh"]




    


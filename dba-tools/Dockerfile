# =====================================================
# NTT Playground - DBA Tools Container (Lightweight)
# For Apple Silicon compatibility - NO Oracle Client
# Connect to Oracle via: docker-compose exec oracle-primary sqlplus
# =====================================================

FROM debian:bookworm-slim

# Prevent interactive prompts during installation
ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies only
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    wget \
    unzip \
    vim-tiny \
    nano \
    less \
    procps \
    net-tools \
    iputils-ping \
    netcat-traditional \
    jq \
    gnupg \
    telnet \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean \
    && apt-get autoremove -y

# Create aliases for convenience
RUN echo 'alias ll="ls -alF"' >> ~/.bashrc && \
    echo 'alias la="ls -A"' >> ~/.bashrc && \
    echo 'export PS1="\[\e[32m\]\u@\h\[\e[0m\]:\[\e[34m\]\w\[\e[0m\]\$ "' >> ~/.bashrc && \
    echo 'echo "========================================"' >> ~/.bashrc && \
    echo 'echo "NTT Playground - DBA Tools Container"' >> ~/.bashrc && \
    echo 'echo "Connect to Oracle: docker-compose exec oracle-primary sqlplus"' >> ~/.bashrc && \
    echo 'echo "========================================"' >> ~/.bashrc

# Create working directory
WORKDIR /scripts

# Default command
CMD ["/bin/bash"]
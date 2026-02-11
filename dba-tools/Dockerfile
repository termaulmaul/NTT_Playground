# =====================================================
# NTT Playground - DBA Tools Container
# Contains: Oracle Instant Client, SQL*Plus, SQLcl
#           mssql-tools, Linux utilities
# =====================================================

FROM ubuntu:22.04

# Prevent interactive prompts during installation
ENV DEBIAN_FRONTEND=noninteractive

# Set Oracle environment variables
ENV ORACLE_HOME=/opt/oracle/instantclient_21_9
ENV LD_LIBRARY_PATH=/opt/oracle/instantclient_21_9
ENV PATH=/opt/oracle/instantclient_21_9:/opt/mssql-tools/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
ENV TNS_ADMIN=/opt/oracle/network/admin

# Install basic dependencies
RUN apt-get update && apt-get install -y \
    curl \
    wget \
    unzip \
    libaio1 \
    libaio-dev \
    libnsl-dev \
    libnss3 \
    libssl-dev \
    vim \
    nano \
    less \
    htop \
    procps \
    net-tools \
    iputils-ping \
    telnet \
    netcat \
    jq \
    git \
    make \
    gcc \
    gnupg \
    lsb-release \
    software-properties-common \
    && rm -rf /var/lib/apt/lists/*

# Install Oracle Instant Client
WORKDIR /opt/oracle

# Download and install Oracle Instant Client Basic
RUN wget -q https://download.oracle.com/otn_software/linux/instantclient/219000/instantclient-basic-linux.x64-21.9.0.0.0dbru.zip && \
    wget -q https://download.oracle.com/otn_software/linux/instantclient/219000/instantclient-sqlplus-linux.x64-21.9.0.0.0dbru.zip && \
    wget -q https://download.oracle.com/otn_software/linux/instantclient/219000/instantclient-tools-linux.x64-21.9.0.0.0dbru.zip && \
    unzip -q instantclient-basic-linux.x64-21.9.0.0.0dbru.zip && \
    unzip -q instantclient-sqlplus-linux.x64-21.9.0.0.0dbru.zip && \
    unzip -q instantclient-tools-linux.x64-21.9.0.0.0dbru.zip && \
    rm -f *.zip && \
    ln -s /opt/oracle/instantclient_21_9/libclntsh.so.21.1 /opt/oracle/instantclient_21_9/libclntsh.so && \
    ln -s /opt/oracle/instantclient_21_9/libocci.so.21.1 /opt/oracle/instantclient_21_9/libocci.so

# Create network admin directory
RUN mkdir -p /opt/oracle/network/admin

# Install SQLcl (Oracle SQL Command Line)
RUN wget -q https://download.oracle.com/otn_software/java/sqldeveloper/sqlcl-22.4.0.0.zip && \
    unzip -q sqlcl-22.4.0.0.zip -d /opt/ && \
    rm -f sqlcl-22.4.0.0.zip && \
    ln -s /opt/sqlcl/bin/sql /usr/local/bin/sqlcl

# Install Microsoft SQL Server tools
RUN curl -sSL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > /etc/apt/trusted.gpg.d/microsoft.gpg && \
    echo "deb [arch=amd64 signed-by=/etc/apt/trusted.gpg.d/microsoft.gpg] https://packages.microsoft.com/ubuntu/22.04/prod jammy main" > /etc/apt/sources.list.d/mssql-release.list && \
    apt-get update && \
    ACCEPT_EULA=Y apt-get install -y msodbcsql17 mssql-tools && \
    rm -rf /var/lib/apt/lists/*

# Create aliases for convenience
RUN echo 'alias sqlplus="sqlplus -L"' >> ~/.bashrc && \
    echo 'alias ll="ls -alF"' >> ~/.bashrc && \
    echo 'alias la="ls -A"' >> ~/.bashrc && \
    echo 'export PATH="$PATH:/opt/mssql-tools/bin"' >> ~/.bashrc && \
    echo 'export PS1="\[\e[32m\]\u@\h\[\e[0m\]:\[\e[34m\]\w\[\e[0m\]\$ "' >> ~/.bashrc

# Create working directory
WORKDIR /scripts

# Default command
CMD ["/bin/bash"]
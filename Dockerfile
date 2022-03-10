# syntax = docker/dockerfile:1.2
FROM jrei/systemd-ubuntu:20.04 as final

# Disable apt cache automatic cleanup in ubuntu image as we manage buildkit cache ourselves
RUN rm -f /etc/apt/apt.conf.d/docker-clean

# Update base, install base dependencies
RUN --mount=type=cache,target=/var/cache/apt \
    echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections && \
    apt-get update && \
    apt-get upgrade -y && \
    apt-get install --no-install-recommends -y \
        apt-transport-https  \
        ca-certificates \
        cron \
        curl \
        gnupg \
        lsb-release \
        sudo  \
        wget && \
    rm -rf /var/lib/apt/lists/*

# Install mysql apt channel for the given mysql version
ARG mysql_version=8
ARG mysql_apt_config_version="0.8.12-1_all"
ARG download_dir="/tmp/"
ARG download_base_url="https://dev.mysql.com/get/"
RUN --mount=type=cache,target=/var/cache/apt \
    echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections && \
    download_package="mysql-apt-config_${mysql_apt_config_version}.deb"; \
    if [ "x${mysql_version}" = "x5" ]; then \
      mysql_version_debconf="5.7"; \
    else  \
      mysql_version_debconf="8.0"; \
    fi && \
    echo "mysql-apt-config mysql-apt-config/repo-distro select ubuntu" | debconf-set-selections && \
    echo "mysql-apt-config mysql-apt-config/repo-codename select bionic" | debconf-set-selections && \
    echo "mysql-apt-config mysql-apt-config/select-server select mysql-${mysql_version_debconf}" \
      | debconf-set-selections && \
    apt-key adv --keyserver keyserver.ubuntu.com --receive-keys 5072E1F5 3A79BD29 && \
    wget -O "${download_dir}/${download_package}" "${download_base_url}/${download_package}" && \
    dpkg -i "${download_dir}/${download_package}" && \
    rm -rf "${download_dir}/${download_package}"

# Install and enable mysql server
ARG MYSQL_ROOT_PASSWORD=test
RUN --mount=type=cache,target=/var/cache/apt \
    echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections && \
    echo "mysql-server mysql-server/root_password password $MYSQL_ROOT_PASSWORD" | debconf-set-selections && \
    echo "mysql-server mysql-server/root_password_again password $MYSQL_ROOT_PASSWORD" | debconf-set-selections && \
    apt-get update && \
    apt-get install --no-install-recommends -y \
        mysql-server && \
    systemctl enable mysql && \
    rm -rf /var/lib/apt/lists/*

CMD ["/lib/systemd/systemd"]
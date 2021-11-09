#!/bin/bash -ex
OS=$(uname -s)
DIST=$(lsb_release -is)
REL=$(lsb_release -cs)
ARCH=$(dpkg --print-architecture)
MACH=$(uname -m)
INIT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"

DOCKER_V="5:20.10.10~3-0~ubuntu-focal"
DOCKER_KEY="https://download.docker.com/linux/${DIST,,}/gpg"
DOCKER_HASH="E2D88D81803C0EBFCD88"
DOCKER_REPO="deb [arch=${ARCH,,}] https://download.docker.com/linux/${DIST,,} ${REL,,} stable"
DOCKER_COMPOSE_V="1.29.2"

# install docker
apt-key adv --keyserver ${DOCKER_KEY} --recv-keys ${DOCKER_HASH: -8}
echo ${DOCKER_REPO} >/etc/apt/sources.list.d/docker.list
apt-get update
apt-get install -y \
    docker-ce=$DOCKER_V \
    docker-ce-cli=$DOCKER_V \
    docker-ce-rootless-extras=$DOCKER_V
apt-mark hold \
    docker-ce \
    docker-ce-cli \
    docker-ce-rootless-extras

cat <<EOF >/etc/docker/daemon.json
{
    "storage-driver": "overlay2",
    "exec-opts": [
        "native.cgroupdriver=systemd"
    ],
    "log-driver": "json-file",
    "log-opts": {
        "max-size": "10m",
        "max-file": "3"
    }
}
EOF

systemctl restart docker.service
usermod -aG docker karl

# install docker compose
curl -sSL "https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_V}/docker-compose-${OS,,}-${MACH,,}" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
ln -sfv /usr/local/bin/docker-compose /usr/bin/docker-compose


#!/usr/bin/env bash

[ -n "$DEBUG" ] && set -e
#exec 3>&1 &>/dev/null

VENV="${1:-.venv}"
ACTIVATE="$VENV/bin/activate"
if grep -qEi 'debian|ubuntu|mint' /etc/*release; then
    PKGMANAGER="apt"
    PKGMANAGER_CACHE="apt update"
elif grep -qEi 'fedora|centos|redhat' /etc/*release; then
    PKGMANAGER="yum"
    PKGMANAGER_CACHE="yum makecache"
else
    echo "OS is not supported."
    exit
fi

pkg_exist () { 
    $PKGMANAGER list --installed 2>/dev/null | grep -qi "^$1" || command -v "$1" &>/dev/null
}

install_deps () {
    
    if ! pkg_exist docker; then
        apt-get -y install ca-certificates gnupg lsb-release
        mkdir -p /etc/apt/keyrings
	curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
            $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
        apt-get update
        apt-get -y install docker-ce docker-ce-cli containerd.io docker-compose-plugin
	usermod -a -G docker etudiant
    else
        echo "[Ok] $(which docker)"
    fi
    
    if ! pkg_exist k3d; then
        wget -q -O - https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash 
    else
        echo "[Ok] $(which k3d)"
    fi
    
	BIN=$(echo ${PATH%%:*})
    mkdir -p "$BIN"
	
    if ! pkg_exist kubectl; then
        curl -Ls "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" -o "$BIN/kubectl"
        chmod +x "$BIN/kubectl" 
    else
        echo "[Ok] $(which kubectl)"
    fi
}

install_deps

echo "######################################################"
echo "Use kubectl ..."


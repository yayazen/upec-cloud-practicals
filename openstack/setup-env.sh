#!/usr/bin/env bash

#OS_PUBLIC_ENDPOINT_FQDN="openstack.dip-tcs.com"
#OS_PUBLIC_ENDPOINT_IPV4="172.24.1.253"

OS_PUBLIC_ENDPOINT_FQDN="horizon.master-oivm.fr"
OS_PUBLIC_ENDPOINT_IPV4="10.10.0.25"



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

enter_venv () {
    local VENV=${1:-".venv"}
    pkg_install python3
	pkg_install build-essential
	pkg_install libssl-dev
	pkg_install libffi-dev
	pkg_install python3-dev
    [ $PKGMANAGER == "apt" ] && pkg_install python3-venv
    python3 -m venv "$VENV" || exit
    source "$VENV/bin/activate"
}

pkg_exist () { 
    $PKGMANAGER list --installed 2>/dev/null | grep -qi "^$1" || command -v "$1" &>/dev/null
}

pkg_install () {
    for pkg in "$@"; do
        if ! pkg_exist "$pkg"; then
            if [ "$EUID" -ne 0 ]; then
                echo "$pkg needs to be installed"
                echo "Please run as root"
            exit
            fi
            $PKGMANAGER_CACHE &>/dev/null
            $PKGMANAGER -y install "$pkg" &>/dev/null && echo "[OK] $pkg" || echo "[Error] $pkg"
        fi
    done
}

install_deps () {
    local REQUIREMENTS=$(mktemp)
cat << EOF > "$REQUIREMENTS"
pip
setuptools
wheel
python-openstackclient
EOF
    pip install --upgrade -r "$REQUIREMENTS"
    rm -f "$REQUIREMENTS"
    
    local BIN=$(echo ${PATH%%:*})
    mkdir -p "$BIN"

    pkg_install curl unzip wget openvpn

    if ! pkg_exist terraform; then
        local TEMPFILE=$(mktemp) 
        curl -Ls https://releases.hashicorp.com/terraform/1.8.5/terraform_1.8.5_linux_amd64.zip \
            -o "$TEMPFILE"
        unzip "$TEMPFILE" -d "$BIN"
        chmod +x "$BIN/terraform"
        rm -f "$TEMPFILE"
    else
        echo "[Ok] $(which terraform)"
    fi
    
 
}

enter_venv "$VENV"
install_deps

# UPEC extra config for debian
for rc in "export OS_CLOUD=openstack"           \
          "export https_proxy="                 \
          "export HTTPS_PROXY="                 \
          "export HTTP_PROXY="                  \
          "export all_proxy="                   \
          "export ALL_PROXY="                   \
          "export no_proxy="                    \
          "export NO_PROXY="                    \
          "export http_proxy=" 
do
    if ! grep -q "$rc" "$VENV/bin/activate"; then
        echo "$rc" >> "$VENV/bin/activate"
    fi
done

if ! grep -q "$OS_PUBLIC_ENDPOINT_FQDN" /etc/hosts; then
    echo "$OS_PUBLIC_ENDPOINT_IPV4 $OS_PUBLIC_ENDPOINT_FQDN" >> /etc/hosts
fi

echo "######################################################"
echo "Enter you lab environment with the following command :"
echo "$ source $VENV/bin/activate"

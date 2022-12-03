#!/usr/bin/env bash
#set -e

[ -n "$DEBUG" ] && set -e

VENV="${1:-.venv}"
ACTIVATE="$VENV/bin/activate"
if grep -qEi 'debian|ubuntu|mint' /etc/*release; then
    PKGMANAGER="apt"
elif grep -qEi 'fedora|centos|redhat' /etc/*release; then
    PKGMANAGER="yum"
else
    echo "OS is not supported."
    exit
fi

OS_PUBLIC_ENDPOINT_FQDN="horizon.master-oivm.fr"
OS_PUBLIC_ENDPOINT_IPV4="10.10.0.2"

enter_venv () {
    local VENV=${1:-".venv"}
    pkg_install python3 python3-venv
    python3 -m venv "$VENV"
    source "$VENV/bin/activate"
}

pkg_exist () { 
    $PKGMANAGER list --installed | grep -qi "^$1" || command -v "$pkg" &>/dev/null
}

pkg_install () {
    for pkg in "$@"; do
        if ! pkg_exist "$pkg"; then
            sudo $PKGMANAGER -y install "$pkg" >/dev/null && echo "[OK] $pkg" || echo "[Error] $pkg"
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

    pkg_install curl unzip openvpn

    if ! pkg_exist terraform; then
        local TEMPFILE=$(mktemp) 
        curl -Ls https://releases.hashicorp.com/terraform/1.2.0/terraform_1.2.0_linux_amd64.zip \
            -o "$TEMPFILE"
        unzip "$TEMPFILE" -d "$BIN"
        chmod +x "$BIN/terraform"
        rm -f "$TEMPFILE"
    fi
    
    if ! pkg_exist k3d; then
        wget -q -O - https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash  
    fi
    
    if ! pkg_exist kubectl; then
        curl -Ls "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" -o "$BIN/kubectl"
        chmod +x "$BIN/kubectl"
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

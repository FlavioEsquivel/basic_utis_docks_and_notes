#!/bin/bash
# Configurar proxy y DNS para Ubuntu sin instalar paquetes ni tocar Docker

PROXY_URL="http://10.158.100.2:8080"
NO_PROXY="127.0.0.1,localhost"
DNS_PRIMARY="10.171.8.4"
DNS_SECONDARY="10.171.8.5"

echo "==> 1. Configurando proxy en /etc/environment..."
sudo bash -c "cat > /etc/environment <<EOF
http_proxy=$PROXY_URL
https_proxy=$PROXY_URL
ftp_proxy=$PROXY_URL
no_proxy=$NO_PROXY
EOF"

echo "==> 2. Exportando variables de entorno para la sesión actual..."
export http_proxy=$PROXY_URL
export https_proxy=$PROXY_URL
export ftp_proxy=$PROXY_URL
export no_proxy=$NO_PROXY
export HTTP_PROXY=$PROXY_URL
export HTTPS_PROXY=$PROXY_URL

echo "==> 3. Configurando proxy para wget..."
sudo sed -i '/^https_proxy/d' /etc/wgetrc
sudo sed -i '/^http_proxy/d' /etc/wgetrc
sudo sed -i '/^ftp_proxy/d' /etc/wgetrc
echo "https_proxy = $PROXY_URL/" | sudo tee -a /etc/wgetrc
echo "http_proxy = $PROXY_URL/" | sudo tee -a /etc/wgetrc
echo "ftp_proxy = $PROXY_URL/" | sudo tee -a /etc/wgetrc

echo "==> 4. Configurando proxy para yum (por si aplica)..."
sudo sed -i '/^proxy=/d' /etc/yum.conf 2>/dev/null || true
echo "proxy=$PROXY_URL" | sudo tee -a /etc/yum.conf 2>/dev/null || true

echo "==> 5. Configurando proxy para pip..."
mkdir -p ~/.pip
cat > ~/.pip/pip.conf <<EOF
[global]
proxy = $PROXY_URL
EOF

echo "==> 6. Configurando DNS en /etc/resolv.conf..."

# Si resolv.conf es un symlink, eliminarlo antes de escribir
if [ -L /etc/resolv.conf ]; then
  echo "==> /etc/resolv.conf es un enlace simbólico, eliminando para poder reescribirlo..."
  sudo rm -f /etc/resolv.conf
fi

sudo bash -c "cat > /etc/resolv.conf <<EOF
nameserver $DNS_PRIMARY
nameserver $DNS_SECONDARY
EOF"

echo "==> Configuración completada. Puedes usar wget, git, pip, etc. con el proxy y DNS corporativo."



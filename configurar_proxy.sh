#!/bin/bash
# Configurar proxy para Ubuntu sin instalar paquetes ni tocar Docker

PROXY_URL="http://10.158.100.2:8080"
NO_PROXY="127.0.0.1,localhost"

# 1. Configurar proxy en /etc/environment (sistema)
echo "Configurando proxy en /etc/environment..."
sudo bash -c "cat > /etc/environment <<EOF
http_proxy=$PROXY_URL
https_proxy=$PROXY_URL
ftp_proxy=$PROXY_URL
no_proxy=$NO_PROXY
EOF"

# Exportar las variables para la sesión actual
export http_proxy=$PROXY_URL
export https_proxy=$PROXY_URL
export ftp_proxy=$PROXY_URL
export no_proxy=$NO_PROXY

# 2. Configurar proxy para wget
echo "Configurando proxy para wget..."
sudo sed -i '/^https_proxy/d' /etc/wgetrc
sudo sed -i '/^http_proxy/d' /etc/wgetrc
sudo sed -i '/^ftp_proxy/d' /etc/wgetrc
echo "https_proxy = $PROXY_URL/" | sudo tee -a /etc/wgetrc
echo "http_proxy = $PROXY_URL/" | sudo tee -a /etc/wgetrc
echo "ftp_proxy = $PROXY_URL/" | sudo tee -a /etc/wgetrc

# 3. Configurar proxy para yum (por si se usa)
echo "Configurando proxy para yum..."
sudo sed -i '/^proxy=/d' /etc/yum.conf
echo "proxy=$PROXY_URL" | sudo tee -a /etc/yum.conf

# 4. Configurar proxy para pip
echo "Configurando proxy para pip..."
mkdir -p ~/.pip
cat > ~/.pip/pip.conf <<EOF
[global]
proxy = $PROXY_URL
EOF

# Exportar variables para la sesión actual (por si pip se ejecuta sin reiniciar)
export HTTP_PROXY=$PROXY_URL
export HTTPS_PROXY=$PROXY_URL

echo "Configuración completada. Puedes usar pip con proxy ahora."


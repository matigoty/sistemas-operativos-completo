#!/bin/bash

# VARIABLES

USUARIO="matias"       # Usuario permitido
PUERTO="22"            # Puerto SSH (cambiar si querés otro)
CLAVE_PUBLICA="~/.ssh/id_rsa.pub"  # Ruta a tu clave pública en la PC

# Instalar OpenSSH si no está

echo "Instalando OpenSSH..."
sudo dnf install -y openssh-server

# Habilitar y arrancar SSH
echo "Habilitando y arrancando el servicio SSH..."
sudo systemctl enable sshd
sudo systemctl start sshd

# Configuración del firewall
echo "Configurando firewall para el puerto SSH..."
sudo firewall-cmd --add-service=ssh --permanent
sudo firewall-cmd --reload

# Hacer backup del sshd_config
echo "Haciendo backup de sshd_config..."
sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak

# Modificar sshd_config
echo "Configurando sshd_config..."

sudo sed -i "s/#PermitRootLogin yes/PermitRootLogin no/" /etc/ssh/sshd_config
sudo sed -i "s/#PasswordAuthentication yes/PasswordAuthentication yes/" /etc/ssh/sshd_config
sudo sed -i "s/#ChallengeResponseAuthentication yes/ChallengeResponseAuthentication no/" /etc/ssh/sshd_config
sudo sed -i "s/#UsePAM yes/UsePAM yes/" /etc/ssh/sshd_config
sudo sed -i "s/#PubkeyAuthentication yes/PubkeyAuthentication yes/" /etc/ssh/sshd_config

# Agregar AllowUsers 
if ! grep -q "AllowUsers ${USUARIO}" /etc/ssh/sshd_config; then
    echo "AllowUsers ${USUARIO}" | sudo tee -a /etc/ssh/sshd_config
fi

# Deshabilitar GSSAPI si existe y está mal escrito
sudo sed -i 's/^GSSAPISAuthenticat.*$/GSSAPIAuthentication no/' /etc/ssh/sshd_config || true

# Reiniciar SSH
echo "Reiniciando SSH..."
sudo systemctl restart sshd

# Configurar clave pública
echo "Agregando clave pública a ${USUARIO}..."
mkdir -p /home/${USUARIO}/.ssh
cat ${CLAVE_PUBLICA} | sudo tee -a /home/${USUARIO}/.ssh/authorized_keys
sudo chown -R ${USUARIO}:${USUARIO} /home/${USUARIO}/.ssh
sudo chmod 700 /home/${USUARIO}/.ssh
sudo chmod 600 /home/${USUARIO}/.ssh/authorized_keys

echo "¡Configuración SSH completada!"

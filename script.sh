#!/bin/bash

#-----Añadir los repositorios de debian12 bookworm-----

# Ruta al archivo sources.list
sources_file="/etc/apt/sources.list"

# Vaciar el archivo sources.list
echo "" | sudo tee $sources_file > /dev/null

# Añadir los nuevos repositorios con espacio entre líneas
echo "# Repositorios principales de Debian Bookworm" | sudo tee -a $sources_file > /dev/null
echo "deb http://deb.debian.org/debian/ bookworm main contrib non-free non-free-firmware" | sudo tee -a $sources_file > /dev/null
echo "deb-src http://deb.debian.org/debian/ bookworm main contrib non-free non-free-firmware" | sudo tee -a $sources_file > /dev/null

# Espacio entre secciones
echo "" | sudo tee -a $sources_file > /dev/null

echo "# Repositorios de seguridad de Debian" | sudo tee -a $sources_file > /dev/null
echo "deb http://security.debian.org/debian-security bookworm-security main contrib non-free non-free-firmware" | sudo tee -a $sources_file > /dev/null
echo "deb-src http://security.debian.org/debian-security bookworm-security main contrib non-free non-free-firmware" | sudo tee -a $sources_file > /dev/null

# Espacio entre secciones
echo "" | sudo tee -a $sources_file > /dev/null

echo "# Actualizaciones de Debian Bookworm" | sudo tee -a $sources_file > /dev/null
echo "deb http://deb.debian.org/debian/ bookworm-updates main contrib non-free non-free-firmware" | sudo tee -a $sources_file > /dev/null
echo "deb-src http://deb.debian.org/debian/ bookworm-updates main contrib non-free non-free-firmware" | sudo tee -a $sources_file > /dev/null

# Espacio entre secciones
echo "" | sudo tee -a $sources_file > /dev/null

echo "# Repositorios de Backports (si los necesitas)" | sudo tee -a $sources_file > /dev/null
echo "deb http://deb.debian.org/debian bookworm-backports main contrib non-free non-free-firmware" | sudo tee -a $sources_file > /dev/null

# Espacio entre secciones
echo "" | sudo tee -a $sources_file > /dev/null



#-----Configuracion de administrador-----

# Verificar si el script se está ejecutando con privilegios de root
if [ "$(id -u)" -ne 0 ]; then
  echo "Este script debe ejecutarse como root."
  exit 1
fi

# Obtener el nombre del usuario real que ejecutó el script (no root)
usuario=$(logname)

# Mostrar el usuario actual
echo "El script se está ejecutando como: $usuario"

# Agregar 'pwfeedback' a 'Defaults mail_badpass' en /etc/sudoers
if grep -q '^Defaults[[:space:]]*mail_badpass' /etc/sudoers; then
  sed -i '/^Defaults[[:space:]]*mail_badpass/s/$/,pwfeedback/' /etc/sudoers
  echo "Se agregó ',pwfeedback' a 'Defaults mail_badpass' en /etc/sudoers."
else
  echo "La línea 'Defaults mail_badpass' no se encontró en /etc/sudoers."
fi

# Verificar si el usuario ya tiene permisos en /etc/sudoers
if ! grep -q "^$usuario[[:space:]]*ALL=(ALL:ALL) ALL" /etc/sudoers; then
  # Añadir el usuario dinámicamente debajo de root
  sed -i "/^root[[:space:]]*ALL=(ALL:ALL) ALL/a $usuario       ALL=(ALL:ALL) ALL" /etc/sudoers
  echo "Se agregó '$usuario       ALL=(ALL:ALL) ALL' debajo de 'root' en /etc/sudoers."
else
  echo "El usuario '$usuario' ya tiene permisos en /etc/sudoers."
fi



# Actualizar sistema y paquetes
sudo apt update && sudo apt dist-upgrade -y

# Crear los directorios clásicos
sudo apt install xdg-user-dirs
xdg-user-dirs-update

# Instalar herramientas de monitoreo y sistema
sudo apt install -y neofetch htop

# Instalar soporte para sistemas de archivos
sudo apt install -y exfat-fuse hfsplus hfsutils ntfs-3g

# Instalar herramientas de compresión
sudo apt install -y p7zip-full p7zip-rar rar unrar zip unzip tar gzip xz-utils

# Instalar utilidades básicas
sudo apt install -y wget curl

# Instalar herramientas de desarrollo y compilación
sudo apt install -y build-essential checkinstall make automake cmake autoconf git git-core dpkg

# Instalar btop para monitoreo de recursos
sudo apt install -y btop

# Instalar herramientas multimedia básicas
sudo apt install -y ffmpeg libavcodec-extra vorbis-tools

# Actualizar sistema y paquetes
sudo apt update && sudo apt dist-upgrade -y

# Instalando entorno gráfico Wayland (Sway + complementos)
sudo apt install -y sway xwayland swaylock

# Crear la copia de la configuracion predeterminada de Sway
mkdir -p ~/.config/sway
cp /etc/sway/config ~/.config/sway/config

# Crear la copia de la configuracion predeterminada de la terminal Foot
mkdir -p ~/.config/foot
cp /etc/xdg/foot/foot.ini ~/.config/foot/foot.ini

# 🔊 Instalando sistema de audio moderno (PipeWire)...
sudo apt install -y pipewire pipewire-audio-client-libraries wireplumber libspa-0.2-bluetooth

# Instalar controlador de brillo
sudo apt install brightnessctl

# Instalar capturador de pantallas
sudo apt install grim wl-clipboard libnotify-bin

# Instalando soporte para cámaras (libcamera)...
sudo apt install -y libcamera-tools libcamera-ipa libcamera-v4l2

# Instalando NetworkManager...
sudo apt install -y network-manager

# Actualizar la lista de paquetes
sudo apt update

#-----Limpiar basuras-----

sudo apt autoremove --purge -y
sudo apt autoremove

# Limpiar archivos temporales
sudo apt autoclean

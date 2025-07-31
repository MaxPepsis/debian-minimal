#!/bin/bash

#-----Añadir los repositorios de debian12 bookworm-----

# Ruta al archivo sources.list
sources_file="/etc/apt/sources.list"

# Vaciar el archivo sources.list
echo "" | tee $sources_file > /dev/null

# Añadir los nuevos repositorios con espacio entre líneas
echo "# Repositorios principales de Debian Bookworm" | tee -a $sources_file > /dev/null
echo "deb http://deb.debian.org/debian/ bookworm main contrib non-free non-free-firmware" | tee -a $sources_file > /dev/null
echo "deb-src http://deb.debian.org/debian/ bookworm main contrib non-free non-free-firmware" | tee -a $sources_file > /dev/null

# Espacio entre secciones
echo "" | tee -a $sources_file > /dev/null

echo "# Repositorios de seguridad de Debian" | tee -a $sources_file > /dev/null
echo "deb http://security.debian.org/debian-security bookworm-security main contrib non-free non-free-firmware" | tee -a $sources_file > /dev/null
echo "deb-src http://security.debian.org/debian-security bookworm-security main contrib non-free non-free-firmware" | tee -a $sources_file > /dev/null

# Espacio entre secciones
echo "" | tee -a $sources_file > /dev/null

echo "# Actualizaciones de Debian Bookworm" | tee -a $sources_file > /dev/null
echo "deb http://deb.debian.org/debian/ bookworm-updates main contrib non-free non-free-firmware" | tee -a $sources_file > /dev/null
echo "deb-src http://deb.debian.org/debian/ bookworm-updates main contrib non-free non-free-firmware" | tee -a $sources_file > /dev/null

# Espacio entre secciones
echo "" | tee -a $sources_file > /dev/null

echo "# Repositorios de Backports (si los necesitas)" | tee -a $sources_file > /dev/null
echo "deb http://deb.debian.org/debian bookworm-backports main contrib non-free non-free-firmware" | tee -a $sources_file > /dev/null

# Espacio entre secciones
echo "" | tee -a $sources_file > /dev/null



#-----Configuracion de administrador-----

# Verificar si el script se está ejecutando con privilegios de root
if [ "$(id -u)" -ne 0 ]; then
  echo "Este script debe ejecutarse como root."
  exit 1
fi

# Obtener el nombre del usuario real que ejecutó el script (no root)
usuario=$(logname)

# Obtener el UID del usuario
uid=$(id -u "$usuario")

home_dir=$(eval echo "~$usuario")

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
apt update && apt dist-upgrade -y

# Instalar sudo para que el usuario tenga permisos de administrador
apt install sudo -y

# Crear los directorios clásicos
apt install xdg-user-dirs -y

echo "Actualizando directorios XDG para el usuario: $usuario"

# Ejecutar el comando como el usuario original
runuser -u "$usuario" -- env XDG_RUNTIME_DIR="/run/user/$uid" xdg-user-dirs-update

# Instalar herramientas de monitoreo y sistema
apt install -y htop

# Instalar soporte para sistemas de archivos
apt install -y exfat-fuse hfsplus hfsutils ntfs-3g

# Instalar herramientas de compresión
apt install -y p7zip-full p7zip-rar rar unrar zip unzip tar gzip xz-utils

# Instalar utilidades básicas
apt install -y wget curl

# Instalar herramientas de desarrollo y compilación
apt install -y build-essential checkinstall make automake cmake autoconf git git-core

# Instalar btop para monitoreo de recursos
apt install -y btop

# Instalar herramientas multimedia básicas
apt install -y ffmpeg libavcodec-extra vorbis-tools

# Actualizar sistema y paquetes
apt update && apt dist-upgrade -y

# Instalar sway
apt install -y sway xwayland swaylock

# Esperar a que sway cree su archivo de configuración
timeout=10
while [ ! -f /etc/sway/config ] && [ $timeout -gt 0 ]; do
    echo "Esperando que /etc/sway/config esté disponible..."
    sleep 1
    timeout=$((timeout - 1))
done

if [ ! -f /etc/sway/config ]; then
    echo "ERROR: No se encontró /etc/sway/config después de esperar. Abortando."
    exit 1
fi

# Crear configuración predeterminada
echo "Configurando sway y foot para el usuario: $usuario"
mkdir -p "$home_dir/.config/sway"
cp -n /etc/sway/config "$home_dir/.config/sway/config"

mkdir -p "$home_dir/.config/foot"
cp -n /etc/xdg/foot/foot.ini "$home_dir/.config/foot/foot.ini"

chown -R "$usuario:$usuario" "$home_dir/.config/sway" "$home_dir/.config/foot"

echo "¡Listo! Configuraciones copiadas."


# 🔊 Instalando sistema de audio moderno (PipeWire)...
apt install -y pipewire pipewire-audio-client-libraries wireplumber libspa-0.2-bluetooth

# Instalar controlador de brillo
apt install brightnessctl -y

# Instalar capturador de pantallas
apt install grim wl-clipboard libnotify-bin -y

# Instalando soporte para cámaras (libcamera)...
apt install -y libcamera-tools libcamera-ipa libcamera-v4l2

# Instalando NetworkManager...
apt install -y network-manager

# Actualizar la lista de paquetes
apt update

#-----Limpiar basuras-----

apt autoremove --purge -y
apt autoremove

# Limpiar archivos temporales
apt autoclean

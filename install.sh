#!/bin/bash

# Establecer la ubicación de instalación
install_dir="/psi"

# Descargar el archivo psi.sh desde la URL
wget https://raw.githubusercontent.com/LAG13-OFC/script-bash/master/psi.sh -O "$install_dir/psi.sh"

# Dar permisos de ejecución al archivo
chmod +x "$install_dir/psi.sh"

# Crear un enlace simbólico para el comando "psi"
sudo ln -s "$install_dir/psi.sh" /usr/local/bin/psi

echo "Instalación completada. Ahora puedes usar el comando 'psi' para acceder al panel de instalación."

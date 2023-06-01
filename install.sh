#!/bin/bash

# Crear el directorio de instalación
install_dir="psiphon"
mkdir -p "$install_dir"

# Descargar el archivo psi.sh desde la URL
wget https://raw.githubusercontent.com/LAG13-OFC/script-bash/master/psi.sh -O "$install_dir/psi.sh"

# Dar permisos de ejecución al archivo
chmod +x "$install_dir/psi.sh"

# Agregar el directorio de instalación al PATH del usuario actual
echo "export PATH=\"$PWD/$install_dir:\$PATH\"" >> ~/.bashrc
source ~/.bashrc

echo "Instalación completada. Ahora puedes usar el comando 'psi' para acceder al panel de instalación."

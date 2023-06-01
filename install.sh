#!/bin/bash

# Establecer la ubicación de instalación
install_dir="/psi"

# Clonar el repositorio de GitHub en el directorio de instalación
git clone https://raw.githubusercontent.com/LAG13-OFC/script-bash/master/psi.sh "$install_dir"

# Crear un enlace simbólico para el comando "psi"
sudo ln -s "$install_dir/psi.sh" /usr/local/bin/psi

echo "Instalación completada. Ahora puedes usar el comando 'psi' para acceder al panel de instalación."

#!/bin/bash

# Establecer la ubicación de instalación
install_dir="/ruta/de/instalacion"

# Clonar el repositorio de GitHub en el directorio de instalación
git clone https://github.com/usuario/repo.git "$install_dir"

# Crear un enlace simbólico para el comando "psi"
sudo ln -s "$install_dir/panel_instalacion.sh" /usr/local/bin/psi

echo "Instalación completada. Ahora puedes usar el comando 'psi' para acceder al panel de instalación."

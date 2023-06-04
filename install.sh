#!/bin/bash

# Crear el directorio de instalación
install_dir="psi"
mkdir -p "$install_dir"

# Descargar el archivo psi.sh desde la URL
wget https://raw.githubusercontent.com/LAG13-OFC/script-bash/master/psi.sh -O "$install_dir/psi.sh"

# Dar permisos de ejecución al archivo
chmod +x "$install_dir/psi.sh"

# Obtener el directorio del archivo de configuración de bash
bash_config_file=
if [ -f "$HOME/.bashrc" ]; then
    bash_config_file="$HOME/.bashrc"
elif [ -f "$HOME/.bash_profile" ]; then
    bash_config_file="$HOME/.bash_profile"
fi

# Agregar el directorio de instalación al PATH del usuario actual en el archivo de configuración de bash
if [ -n "$bash_config_file" ]; then
    echo "export PATH=\"$PWD/$install_dir:\$PATH\"" >> "$bash_config_file"
    echo "alias psi=\"$PWD/$install_dir/psi.sh\"" >> "$bash_config_file" # Agrega esta línea para crear el alias
    source "$bash_config_file"
    echo "El directorio de instalación se ha agregado al PATH del usuario actual."
else
    echo "No se encontró el archivo de configuración de bash (.bashrc o .bash_profile). Asegúrate de agregar manualmente \"$PWD/$install_dir\" al PATH y crear un alias para 'psi.sh'."
fi

echo "Instalación completada. Ahora puedes usar el comando 'psi' para acceder al panel de instalación."

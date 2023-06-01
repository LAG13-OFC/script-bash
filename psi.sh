#!/bin/bash

# Función para instalar Psiphon
function install_psiphon() {
    # Crear directorio de instalación
    install_dir="psiphon"
    mkdir -p "$install_dir"
    cd "$install_dir" || exit 1

    # Descargar el archivo Psiphon
    wget 'https://docs.google.com/uc?export=download&id=1AuP6XISWohM0NbUyItnQeN1F7Ayj85Ez' -O 'psiphond'

    # Otorgar permisos de ejecución al archivo Psiphon
    chmod 775 psiphond

    # Generar la configuración de Psiphon
    ./psiphond --ipaddress 0.0.0.0 --protocol FRONTED-MEEK-HTTP-OSSH:"$1" --protocol FRONTED-MEEK-OSSH:"$2" generate

    echo "Psiphon instalado correctamente en el directorio: $PWD"
}

# Función para desinstalar Psiphon y desactivar los puertos TCP seleccionados
function uninstall_psiphon() {
    install_dir="psiphon"
    http_port="$1"
    ossh_port="$2"
    
    # Detener y eliminar cualquier proceso de Psiphon en ejecución
    sudo pkill -f psiphond
    sudo pkill -f psiphon-tunnel-core

    # Eliminar el directorio de instalación
    sudo rm -rf "$install_dir"

    # Desactivar los puertos TCP seleccionados
    sudo ufw deny "$http_port"
    sudo ufw deny "$ossh_port"

    echo "Psiphon desinstalado correctamente y los puertos TCP $http_port y $ossh_port han sido desactivados."
}

# Función para ver los puertos activos
function view_active_ports() {
    sudo netstat -tuln
}

# Función para ver el contenido del archivo server-entry.dat
function view_server_entry() {
    install_dir="psiphon"
    server_entry_file="$install_dir/server-entry.dat"

    if [ -f "$server_entry_file" ]; then
        cat "$server_entry_file"
    else
        echo "El archivo server-entry.dat no existe en la ubicación de instalación."
    fi
}

# Menú principal
while true; do
    echo "Bienvenido al panel de instalación y visualización de puertos."
    echo "Por favor, elige una opción:"
    echo "1. Instalar Psiphon"
    echo "2. Desinstalar Psiphon y desactivar puertos TCP seleccionados"
    echo "3. Ver los puertos activos"
    echo "4. Ver el contenido del archivo server-entry.dat"
    echo "5. Salir"
    echo

    read -p "Opción seleccionada: " option

    case $option in
        1)
            read -p "Ingresa el puerto para el protocolo FRONTED-MEEK-HTTP-OSSH (8080 por defecto): " http_port
            http_port=${http_port:-8080}

            read -p "Ingresa el puerto para el protocolo FRONTED-MEEK-OSSH (443 por defecto): " ossh_port
            ossh_port=${ossh_port:-443}

            install_psiphon "$http_port" "$ossh_port"
            ;;
        2)
            read -p "Ingresa el puerto para el protocolo FRONTED-MEEK-HTTP-OSSH: " http_port
            read -p "Ingresa el puerto para el protocolo FRONTED-MEEK-OSSH: " ossh_port

            uninstall_psiphon "$http_port" "$ossh_port"
            ;;
        3)
            view_active_ports
            ;;
        4)
            view_server_entry
            ;;
        5)
            echo "Saliendo del programa."
            exit
            ;;
        *)
            echo "Opción inválida. Por favor, elige una opción válida."
            ;;
    esac

    echo
done

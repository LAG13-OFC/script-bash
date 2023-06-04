#!/bin/bash

# Ruta de instalación de Psiphon
install_dir="$HOME/psi"

# Función para instalar Psiphon
function install_psiphon() {
    # Crear directorio de instalación
    mkdir -p "$install_dir"
    cd "$install_dir" || exit 1

    # Descargar el archivo Psiphon
    wget 'https://docs.google.com/uc?export=download&id=1AuP6XISWohM0NbUyItnQeN1F7Ayj85Ez' -O 'psiphond'

    # Otorgar permisos de ejecución al archivo Psiphon
    chmod 775 psiphond

    # Generar la configuración de Psiphon
    ./psiphond --ipaddress 0.0.0.0 --protocol FRONTED-MEEK-HTTP-OSSH:"$1" --protocol FRONTED-MEEK-OSSH:"$2" generate

    echo "Psiphon instalado correctamente en el directorio: $install_dir"
}

# Función para desinstalar Psiphon y desactivar los puertos TCP seleccionados
function uninstall_psiphon() {
    http_port="$1"
    ossh_port="$2"
    cd
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

# Función para ver los puertos activos de Psiphon
function view_active_psiphon_ports() {
    active_ports=$(sudo netstat -tuln | awk 'NR>2 {print $4}' | grep -oP '(?<=:)\d+$')
    if [[ -n $active_ports ]]; then
        echo "Puertos de Psiphon activos: $active_ports"
    fi
}

# Función para ver los puertos activos
function view_active_ports() {
    sudo netstat -tuln | awk 'NR>2 {print $4}'
}

# Función para iniciar Psiphon
function start_psiphon() {
    cd "$install_dir" || exit 1
    nohup sudo ./psiphond run >/dev/null 2>&1 &
    echo "Psiphon iniciado."
}

# Función para ver el contenido del archivo server-entry.dat
function view_server_entry() {
    server_entry_file="$install_dir/server-entry.dat"

    if [ -f "$server_entry_file" ]; then
        cat "$server_entry_file"
    else
        echo "El archivo server-entry.dat no existe en la ubicación de instalación."
    fi
}

# Menú principal
while true; do
    clear  # Limpia la pantalla

    echo "Bienvenido al panel de instalación de Psiphon."
    echo "Por favor, elige una opción:"
    echo "1. Instalar Psiphon"
    echo "2. Iniciar Psiphon"
    echo "3. Desinstalar Psiphon y desactivar puertos TCP seleccionados"
    echo "4. Ver los puertos activos"
    echo "5. Ver los puertos activos de Psiphon"
    echo "6. Ver el contenido del archivo server-entry.dat"
    echo "7. Salir"
    echo

    # Mostrar puertos activos de Psiphon (opción 5)
    view_active_psiphon_ports

    read -p "Opción seleccionada: " option

    case $option in
        1)
            clear  # Limpia la pantalla
            read -p "Ingresa el puerto para el protocolo FRONTED-MEEK-HTTP-OSSH (8080 por defecto): " http_port
            http_port=${http_port:-8080}

            read -p "Ingresa el puerto para el protocolo FRONTED-MEEK-OSSH (443 por defecto): " ossh_port
            ossh_port=${ossh_port:-443}

            install_psiphon "$http_port" "$ossh_port"
            echo "Psiphon instalado."
            read -n 1 -s -r -p "Presiona ENTER para continuar."
            ;;
        2)
            clear  # Limpia la pantalla
            start_psiphon
            read -n 1 -s -r -p "Presiona ENTER para continuar."
            ;;
        3)
            clear  # Limpia la pantalla
            read -p "Ingresa el puerto para el protocolo FRONTED-MEEK-HTTP-OSSH: " http_port
            read -p "Ingresa el puerto para el protocolo FRONTED-MEEK-OSSH: " ossh_port

            uninstall_psiphon "$http_port" "$ossh_port"
            read -n 1 -s -r -p "Presiona ENTER para continuar."
            ;;
        4)
            clear  # Limpia la pantalla
            echo "Puertos TCP activos:"
            view_active_ports
            read -n 1 -s -r -p "Presiona ENTER para continuar."
            ;;
        5)
            clear  # Limpia la pantalla
            view_active_psiphon_ports
            read -n 1 -s -r -p "Presiona ENTER para continuar."
            ;;
        6)
            clear  # Limpia la pantalla
            view_server_entry
            read -n 1 -s -r -p "Presiona ENTER para continuar."
            ;;
        7)
            echo "Saliendo del programa."
            exit
            ;;
        *)
            echo "Opción inválida. Por favor, elige una opción válida."
            read -n 1 -s -r -p "Presiona ENTER para continuar."
            ;;
    esac
done

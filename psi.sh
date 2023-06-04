#!/bin/bash

# Ruta de instalación de Psiphon
install_dir="$HOME/psi"
http_port=
ossh_port=
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

# Función para detener los servicios de Psiphon
function stop_psiphon() {
    sudo pkill -f psiphond
    sudo pkill -f psiphon-tunnel-core
}

# Función para desactivar los puertos activos de Psiphon
function disable_psiphon_ports() {
    active_ports=$(sudo netstat -tuln | awk 'NR>2 {print $4}' | grep -E '8080|443' | grep "$install_dir" | awk -F ":" '{print $NF}')
    for port in $active_ports; do
        sudo ufw deny "$port"
    done
}

# Función para desinstalar Psiphon
function uninstall_psiphon() {
    stop_psiphon
    disable_psiphon_ports

    # Eliminar el directorio de instalación
    sudo rm -rf "$install_dir"

    echo "Psiphon desinstalado correctamente y los puertos de Psiphon han sido desactivados."
}

# Función para ver los puertos activos de Psiphon

  function view_active_psiphon_ports() {
    service_name="psiphon"  # Nombre del servicio Psiphon

    active_ports=$(sudo lsof -i -P -n | grep "$service_name" | awk -F ":" '{print $2}')
    if [[ -n $active_ports ]]; then
        echo "Puertos de Psiphon activos:"
        while read -r port; do
            protocol=$(sudo lsof -i -P -n | awk -v port="$port" '$9 ~ port {print $9}')
            if [[ $protocol == $http_port ]]; then
                echo "Puerto: $port (HTTP)"
            elif [[ $protocol == $ossh_port ]]; then
                echo "Puerto: $port (HTTPS)"
            else
                echo "Puerto: $port (Protocolo desconocido)"
            fi
        done <<< "$active_ports"
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
    # Mostrar puertos activos de Psiphon (opción 5)
    view_active_psiphon_ports
    echo
    echo "Bienvenido al panel de instalación de Psiphon.23"
    echo "Por favor, elige una opción:"
    echo "1. INSTALAR Psiphon"
    echo "2. INICIAR Psiphon"
    echo "3. DETENER Psiphon"
    echo "4. DESINSTALAR Script"
    echo "5. Ver los puertos activos"
    echo "6. Ver los puertos activos de Psiphon"
    echo "7. Ver la config"
    echo "0. Salir"
    echo

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
            stop_psiphon
            disable_psiphon_ports
            echo "Pesiphon detenido."
            read -n 1 -s -r -p "Presiona ENTER para continuar."
            ;;


        4)
            clear  # Limpia la pantalla
            uninstall_psiphon
            echo "Saliendo del programa."
            exit
            ;;   
        5)
            clear  # Limpia la pantalla
            echo "Puertos TCP activos:"
            view_active_ports
            read -n 1 -s -r -p "Presiona ENTER para continuar."
            ;;
        6)
            clear  # Limpia la pantalla
            view_active_psiphon_ports
            read -n 1 -s -r -p "Presiona ENTER para continuar."
            ;;
        7)
            clear  # Limpia la pantalla
            view_server_entry
            echo
            read -n 1 -s -r -p "Presiona ENTER para continuar."
            ;;
        0)
            clear  # Limpia la pantalla
            echo "Saliendo del programa."
            exit
            ;;
        *)
            echo "Opción inválida. Por favor, elige una opción válida."
            read -n 1 -s -r -p "Presiona ENTER para continuar."
            ;;
    esac
done

#!/bin/bash
# Ruta de instalación de Psiphon
install_dir="$HOME/psi"
http_port=""
https_port=""

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
    ./psiphond --ipaddress 0.0.0.0 --protocol FRONTED-MEEK-HTTP-OSSH:"$http_port" --protocol FRONTED-MEEK-OSSH:"$https_port" generate

    echo "Psiphon instalado correctamente en el directorio: $install_dir"
}

# Función para ver los puertos activos de Psiphon
function view_active_psiphon_ports() {
    service_name="psiphon"  # Nombre del servicio Psiphon

    active_ports=$(sudo lsof -i -P -n | grep "$service_name" | awk -F ":" '{print $2}')
    if [[ -n $active_ports ]]; then
        echo "             Puertos de Psiphon activos:"
      echo "================================================================"
        while read -r port; do
            # Eliminar (LISTEN) y espacios en blanco
            port=$(echo "$port" | sed 's/(LISTEN)//' | tr -d '[:space:]')
            protocol=$(sudo lsof -i -P -n | awk -v port="$port" '$9 ~ port {print $1}')
            if [[ $port == $http_port ]]; then
                echo " FRONTED-MEEK-HTTP-OSSH: $port"
            elif [[ $port == $https_port ]]; then
                echo " FRONTED-MEEK-OSSH: $port "
            else
                echo " Desconocido: $port"
            fi
        done <<< "$active_ports"
    fi
}

# Función para detener los servicios de Psiphon
function stop_psiphon() {
    sudo pkill -f psiphond
    sudo pkill -f psiphon-tunnel-core
}

# Función para desactivar los puertos activos de Psiphon
function disable_psiphon_ports() {
    active_ports=$(sudo netstat -tuln | awk 'NR>2 {print $4}' | awk -F ":" '{print $NF}')
    for port in $active_ports; do
        if [[ $port == $http_port ]] || [[ $port == $https_port ]]; then
            sudo ufw deny "$port"
        fi
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

# Función para ver los puertos activos
function view_active_ports() {
    sudo netstat -tln 
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
    # Mostrar puertos activos de Psiphon (opción 6)
    echo "================================================================"
    echo -e "\e[1m\e[31;1m                     By |@LAG13_OFC                     \e[0m"
    echo "================================================================"
    echo "================================================================"
    echo -e "   \e[1m\e[93m       Bienvenido al panel de instalación de Psiphon       \e[0m"
    echo "================================================================"
    view_active_psiphon_ports
    echo "================================================================"
    echo -e " \e[1m\e[31m Por favor, elige una opción:\e[0m"
    echo -e " \e[1m\e[93m[\e[0m\e[1m\e[32m1\e[0m\e[1m\e[93m]\e[0m\e[1m\e[31m>\e[0m \e[1m\e[36mINSTALAR Psiphon\e[0m"
    echo -e " \e[1m\e[93m[\e[0m\e[1m\e[32m2\e[0m\e[1m\e[93m]\e[0m\e[1m\e[31m>\e[0m \e[1m\e[36mINICIAR Psiphon\e[0m"
    echo -e " \e[1m\e[93m[\e[0m\e[1m\e[32m3\e[0m\e[1m\e[93m]\e[0m\e[1m\e[31m>\e[0m \e[1m\e[36mDETENER Psiphon\e[0m"
    echo -e " \e[1m\e[93m[\e[0m\e[1m\e[32m4\e[0m\e[1m\e[93m]\e[0m\e[1m\e[31m>\e[0m \e[1m\e[36mDESINSTALAR Psiphon\e[0m"
    echo -e " \e[1m\e[93m[\e[0m\e[1m\e[32m5\e[0m\e[1m\e[93m]\e[0m\e[1m\e[31m>\e[0m \e[1m\e[36mVer los puertos activos\e[0m"
    echo -e " \e[1m\e[93m[\e[0m\e[1m\e[32m6\e[0m\e[1m\e[93m]\e[0m\e[1m\e[31m>\e[0m \e[1m\e[36mVer la configuración de Psiphon\e[0m"
    echo -e " \e[1m\e[93m[\e[0m\e[1m\e[32m0\e[0m\e[1m\e[93m]\e[0m\e[1m\e[31m>\e[0m \e[1m\e[36mSalir\e[0m"

   
    # Función para imprimir el prompt con el color deseado
    print_prompt() {
    local prompt="\e[1m\e[31m--->\e[0m \e[1m\e[93mOpción seleccionada: [0m"
    echo -e "$prompt"
    }

    # Imprimir el prompt con el color deseado y leer la opción del usuario
    print_prompt; read -p "" option


    case $option in
        1)
            clear  # Limpia la pantalla
            read -p "Ingresa el puerto para el protocolo FRONTED-MEEK-HTTP-OSSH (8080 por defecto): " http_port
            http_port=${http_port:-8080}

            read -p "Ingresa el puerto para el protocolo FRONTED-MEEK-OSSH (443 por defecto): " https_port
            https_port=${https_port:-443}

            install_psiphon
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
            echo "Psiphon detenido."
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
            echo "Todos Puertos TCP activos:"
            view_active_ports
            read -n 1 -s -r -p "Presiona ENTER para continuar."
            ;;
        6)
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

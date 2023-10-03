#!/bin/bash
install_dir="/opt/MHSOC/"
function install_wserver() {
    echo -e "- Instalando Pacotes Wazuh"
    apt-get install wazuh-manager
    if [ $? -eq 0 ]; then
        echo "- Wazuh: Instalado com sucesso"
        systemctl daemon-reload
        systemctl enable wazuh-manager
        systemctl restart wazuh-manager
        if [ $? -eq 0 ]; then
            echo "- Wazuh: Iniciado com sucesso"
        else
            echo "- Wazuh: Erro ao iniciar o Wazuh"
            exit 600
        fi
    else
        echo "- Wazuh: Erro ao instalar o Wazuh"
        exit 600
    fi     
}

if [ "$(id -u)" != "0" ]; then
    echo "Este script deve ser executado como root."
    exit 1
else
    install_wserver
fi
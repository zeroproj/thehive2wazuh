#!/bin/bash
P_01="$1"
function install_dependencies() {
    apt-get install apt-transport-https zip unzip lsb-release curl gnupg -y
    apt-get install -y openjdk-8-jre-headless
    apt install python3-pip -y
}
function install_elasticsearch() {
    echo -e "- Configurando Repositorio Elastic"
    curl -s https://artifacts.elastic.co/GPG-KEY-elasticsearch | gpg --no-default-keyring --keyring gnupg-ring:/usr/share/keyrings/elasticsearch.gpg --import && chmod 644 /usr/share/keyrings/elasticsearch.gpg
    echo "deb [signed-by=/usr/share/keyrings/elasticsearch.gpg] https://artifacts.elastic.co/packages/7.x/apt stable main" | tee /etc/apt/sources.list.d/elastic-7.x.list
}
function install_wserver() {
    echo -e "- Configurando Repositorio WServer"
    curl -s https://packages.wazuh.com/key/GPG-KEY-WAZUH | gpg --no-default-keyring --keyring gnupg-ring:/usr/share/keyrings/wazuh.gpg --import && chmod 644 /usr/share/keyrings/wazuh.gpg
    echo "deb [signed-by=/usr/share/keyrings/wazuh.gpg] https://packages.wazuh.com/4.x/apt/ stable main" | tee -a /etc/apt/sources.list.d/wazuh.list
}
function conf_java() {
    echo JAVA_HOME="/usr/lib/jvm/java-8-openjdk-amd64" >> /etc/environment
    export JAVA_HOME="/usr/lib/jvm/java-8-openjdk-amd64"
}

function conf_cassandra() {
    curl -fsSL https://www.apache.org/dist/cassandra/KEYS | sudo apt-key add -
    echo "deb https://debian.cassandra.apache.org 40x main" | sudo tee -a /etc/apt/sources.list.d/cassandra.sources.list
}

function install_thehive() {
    curl https://raw.githubusercontent.com/TheHive-Project/TheHive/master/PGP-PUBLIC-KEY | sudo apt-key add -
    echo 'deb https://deb.thehive-project.org release main' | sudo tee -a /etc/apt/sources.list.d/thehive-project.list
}

if [ "$(id -u)" != "0" ]; then
    echo "Este script deve ser executado como root."
    exit 1
else
    if [ "$P_01" == "-a" ]; then
        apt update
        install_dependencies
        install_elasticsearch
        install_wserver
        conf_java
        conf_cassandra
        install_thehive
        apt update
    elif [ "$P_01" == "-c" ]; then
    echo "O argumento -c foi fornecido."
    elif [ "$P_01" == "-d" ]; then
    echo "O argumento -d foi fornecido."
    else
    echo "Uso: $0 [-a] [-c] [-d]" >&2
    exit 1
    fi
fi
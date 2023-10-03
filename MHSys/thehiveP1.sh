#!/bin/bash
install_dir="/opt/MHSOC/"

function install_cassandra() {
    echo -e "- Instalando Pacotes Cassandra"
    apt install cassandra
    if [ $? -eq 0 ]; then
        echo "- Cassandra: Instalado com sucesso"
        sleep 120
        CQLSH_CMD="cqlsh"
        $CQLSH_CMD -f $install_dir'MHConf/atualizar_cluster.cql'
        nodetool flush
        if [ $? -eq 0 ]; then
            echo "- Cassandra: Update Base"
        else
            echo "- Cassandra: Erro Update Base"
            exit 600
        fi
    else
        echo "- Cassandra: Erro ao instalar"
        exit 600
    fi     
}

function cassandra_conf(){
    sed -i "s/cluster_name: 'Test Cluster'/cluster_name: 'thp'/" /etc/cassandra/cassandra.yaml
    sed -i "s/^# hints_directory: \/var\/lib\/cassandra\/hints/hints_directory: \/var\/lib\/cassandra\/hints/" /etc/cassandra/cassandra.yaml
    systemctl restart cassandra
    if [ $? -eq 0 ]; then
        echo "- Cassandra: Serviço iniciado"
    else
        echo "- Cassandra: Erro ao iniciar o serviço"
        exit 600
    fi
    mkdir -p /opt/thp/thehive/index
    mkdir -p /opt/thp/thehive/files
    mkdir -p /opt/thp/thehive/database
}

function install_thehive(){
    apt-get install thehive4
    if [ $? -eq 0 ]; then
        echo "- Thehive: Instalado com sucesso"
    else
        echo "- Thehive: Erro ao instalar"
        exit 600
    fi
}

function thehive_conf(){
    chown thehive:thehive /opt/thp/thehive/index
    chown thehive:thehive /opt/thp/thehive/files
    chown thehive:thehive /opt/thp/thehive/database
    unlink /etc/thehive/application.conf
    rm /etc/thehive/application.conf
    ln -s $install_dir'MHConf/application.conf' /etc/thehive/application.conf
    if [ $? -eq 0 ]; then
        echo "- Thehive: Configurado com sucesso"
    else
        echo "- Thehive: Erro ao configurar"
        exit 600
    fi
    chown thehive:thehive /etc/thehive/application.conf
}

function start_thehive() {
    systemctl restart thehive
    if [ $? -eq 0 ]; then
        echo "- Thehive: Serviço iniciado"
        echo ""
        echo "#####################################################################"
        echo "# O usuário de acesso TheHive                                       #"
        echo "##########################################                          #"
        echo "# Usuario: admin@thehive.local           #                          #"
        echo "# Senha: secret                          #                          #"
        echo "# Recomenda-se alterar a senha padrão.   #                          #"
        echo "##########################################                          #"
        echo "#                                                                   #"
        echo "#####################################################################"
        echo "# Acesse o seguinte documento no link abaixo:                       #"   
        echo "# https://github.com/zeroproj/MHSoc/blob/main/MHDoc/TheHiveApi.md   #" 
        echo "# Realize a configuração do TheHive e gere a chave API necessária.  #"
        echo "# Após ter todos os dados, inicie a segunda                         #"
        echo "# parte da configuração do TheHive.                                 #"
        echo "# Comando: /opt/MHSOC/MHSys/thehiveP2.sh                            #"
        echo "#####################################################################"
        echo ""
        read -p "Pressione Enter para continuar..."
    else
        echo "- Thehive: Erro ao iniciar o serviço"
        exit 600
    fi
}

if [ "$(id -u)" != "0" ]; then
    echo "Este script deve ser executado como root."
    exit 1
else
    install_cassandra
    cassandra_conf
    install_thehive
    thehive_conf
    start_thehive
fi

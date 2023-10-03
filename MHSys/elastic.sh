#!/bin/bash
install_dir="/opt/MHSOC/"
senha_elastic=""


function install_elasticsearch() {
    echo -e "- Instalando Pacotes Elasticsearch"
    apt-get install elasticsearch=7.17.12
    if [ $? -eq 0 ]; then
        echo "- Elasticsearch: Instalado com sucesso"
        systemctl daemon-reload
        systemctl enable elasticsearch
        if [ $? -eq 0 ]; then
            echo "- Elasticsearch: Habilitado com sucesso"
        else
            echo "- Elasticsearch: Erro ao habilitar o Elasticsearch"
            exit 100
        fi
    else
        echo "- Elasticsearch: Erro ao instalar o Elasticsearch"
        exit 100
    fi
}

function config_elasticsearch() {
    echo -e "- Baixando arquivo de configuração Elasticsearch"
    unlink /etc/elasticsearch/elasticsearch.yml
    ln -s $install_dir'MHConf/elasticsearch.yml' /etc/elasticsearch/elasticsearch.yml
    if [ $? -eq 0 ]; then
        echo "- Elasticsearch: Configurado com sucesso"
    else
        echo "- Elasticsearch: Erro ao configurar o Elasticsearch"
        exit 100
    fi
}

function config_cert() {
    echo -e "- Baixando arquivo de configuração Certificado"
    unlink /usr/share/elasticsearch/instances.yml
    ln -s $install_dir'MHConf/instances.yml' /usr/share/elasticsearch/instances.yml
    /usr/share/elasticsearch/bin/elasticsearch-certutil cert ca --pem --in /usr/share/elasticsearch/instances.yml --keep-ca-key --out ~/certs.zip
    unzip ~/certs.zip -d ~/certs
    if [ $? -eq 0 ]; then
        echo "- Elasticsearch: Certificado gerado com sucesso"
    else
        echo "- Elasticsearch: Erro ao gerar o certiticado"
        exit 100
    fi
    mkdir /etc/elasticsearch/certs/ca -p
    cp -R ~/certs/ca/ ~/certs/MHelastic/* /etc/elasticsearch/certs/
    chown -R elasticsearch: /etc/elasticsearch/certs
    chmod -R 500 /etc/elasticsearch/certs
    chmod 400 /etc/elasticsearch/certs/ca/ca.* /etc/elasticsearch/certs/MHelastic.*
    rm -rf ~/certs/ ~/certs.zip
}

function start_elasticsearch() {
    systemctl restart elasticsearch
    if [ $? -eq 0 ]; then
        echo "- Elasticsearch: Serviço iniciado"
    else
        echo "- Elasticsearch: Erro ao iniciar o serviço"
        exit 100
    fi
}

function gerate_user_elasticsearch() {
    passwords=$(echo -e "Y\n" | /usr/share/elasticsearch/bin/elasticsearch-setup-passwords auto)
    if [ $? -eq 0 ]; then
        echo "$passwords" > $install_dir'MHSocSenha.txt'
        senha_elastic=$(grep 'PASSWORD elastic' $install_dir'MHSocSenha.txt' | awk '{print $NF}')
        cat $install_dir'MHSocSenha.txt'
        echo ""
        echo "################################################################"
        echo "# Por favor, salve as senhas geradas acima em um local seguro. #"
        echo "################################################################"
        echo ""
        read -p "Pressione Enter para continuar..."
    else
        echo "- Elasticsearch: Falha ao gerar as credencias de acesso"
        exit 100
    fi
}

function test_system_all(){
    response=$(curl -XGET https://localhost:9200 -u elastic:"$senha_elastic" -k)
    if [[ $response == *"\"name\" : \"MHelastic\""* ]]; then
        echo "- Elasticsearch: Configurado com Sucesso."
    else
        echo "- Elasticsearch: Falha geral do processo de comnfiguraçao do Elasticsearch"
        exit 100
    fi
} 

if [ "$(id -u)" != "0" ]; then
    echo "Elasticsearch: Este script deve ser executado como root."
    exit 1
else
    install_elasticsearch
    config_elasticsearch
    config_cert
    start_elasticsearch
    gerate_user_elasticsearch
    test_system_all
fi
#!/bin/bash
install_dir="/opt/MHSOC/"
function install_beat() {
    echo -e "- Instalando Pacotes FileBeat"
    apt-get install filebeat=7.17.12
    if [ $? -eq 0 ]; then
        echo "- FileBeat: Instalado com sucesso"
        systemctl daemon-reload
        systemctl enable filebeat
    else
        echo "- FileBeat: Instalado com sucesso"
        exit 300
    fi

}

function template_beat() {
    echo -e "- Instalando Template FileBeat"
    unlink /etc/filebeat/wazuh-template.json
    ln -s $install_dir'MHConf/wazuh-template45.json' /etc/filebeat/wazuh-template.json
    if [ $? -eq 0 ]; then
        echo "- FileBeat: Configurado com sucesso"
        chmod go+r /etc/filebeat/wazuh-template.json
    else
        echo "- FileBeat: Falha ao configurar"
        exit 300
    fi
}

function wserver_beat() {
    echo -e "- Instalando Integracão WServer e FileBeat"
    tar -xvzf $install_dir'MHConf/wazuh-filebeat-0.2.tar.gz' -C /usr/share/filebeat/module
    if [ $? -eq 0 ]; then
        echo "- FileBeat: Integracão Wazuh e FileBeat concluida"
    else
        echo "- FileBeat: Falha na integracão Wazuh e FileBeat"
        exit 300
    fi
}

function beat_con() {
    echo -e "- Instalando Integracão FileBeat"
    senha_elastic=$(grep 'PASSWORD elastic' $install_dir'MHSocSenha.txt' | awk '{print $NF}')
    sed -i "s/output.elasticsearch.password: <elasticsearch_password>/output.elasticsearch.password: $senha_elastic/g" $install_dir'MHConf/filebeat.yml'
    unlink /etc/filebeat/filebeat.yml
    ln -s $install_dir'MHConf/filebeat.yml' /etc/filebeat/filebeat.yml
    if [ $? -eq 0 ]; then
        echo "- FileBeat: Integracão FileBea concluida"
    else
        echo "- FileBeat: Falha na integracão FileBeat"
        exit 300
    fi
}

function beat_cert() {
    cp -r /etc/elasticsearch/certs/ca/ /etc/filebeat/certs/
    cp /etc/elasticsearch/certs/MHelastic.crt /etc/filebeat/certs/filebeat.crt
    cp /etc/elasticsearch/certs/MHelastic.key /etc/filebeat/certs/filebeat.key
}

function start_filebeat() {
    systemctl restart filebeat
    if [ $? -eq 0 ]; then
        echo "- FileBeat: Serviço iniciado"
    else
        echo "- FileBeat: Erro ao iniciar o serviço"
        exit 300
    fi
}

function test_system_all(){
    response=$(filebeat test output)
    if [[ $response == *"talk to server... OK"* ]]; then
        echo "- Filebeat: Configurado com Sucesso"
    else
        exit 300
    fi
} 
if [ "$(id -u)" != "0" ]; then
    echo "Este script deve ser executado como root."
    exit 1
else
    install_beat
    template_beat
    wserver_beat
    beat_con
    beat_cert
    start_filebeat
    test_system_all
fi
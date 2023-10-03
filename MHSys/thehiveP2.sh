#!/bin/bash
install_dir="/opt/MHSOC/"


function instal_thehive4py(){
  /var/ossec/framework/python/bin/pip3 install thehive4py==1.8.1
  if [ $? -eq 0 ]; then
    echo "- Thehive: Thehive4py Instalado com sucesso"
  else
    echo "- Thehive: Erro ao instala Thehive4py"
    exit 700
  fi
}

function config_wserver_inter(){
  ln -s $install_dir'MHConf/custom-w2thive.py' /var/ossec/integrations/custom-w2thive.py
  if [ $? -eq 0 ]; then
    echo "- Thehive: Integração configurada com sucesso: custom-w2thive.py"
  else
    echo "- Thehive: Erro ao instalar"
    exit 700
  fi
  ln -s $install_dir'MHConf/custom-w2thive' /var/ossec/integrations/custom-w2thive
  if [ $? -eq 0 ]; then
    echo "- Thehive: Integração configurada com sucesso: custom-w2thive"
  else
    echo "- Thehive: Erro ao instalar"
    exit 700
  fi
  ln -s /var/ossec/logs/integrations.log $install_dir'logs/integrations.log'
  sudo chmod 755 /var/ossec/integrations/custom-w2thive.py
  sudo chmod 755 /var/ossec/integrations/custom-w2thive
  sudo chown root:wazuh /var/ossec/integrations/custom-w2thive.py
  sudo chown root:wazuh /var/ossec/integrations/custom-w2thive
}

function conf_api(){
  read -p "Digite a chave de API: " api_key
  if [ -z "$api_key" ]; then
      echo "- Thehive: A chave de API não pode estar em branco. Saindo."
      exit 700
  fi
  config_file="/var/ossec/etc/ossec.conf"
  if [ ! -f "$config_file" ]; then
      echo "- Thehive: O arquivo $config_file não foi encontrado. Saindo."
      exit 700
  fi
  sed -i '/<\/ossec_config>/i \
    <integration>\
      <name>custom-w2thive</name>\
      <hook_url>127.0.0.1:9000</hook_url>\
      <api_key>'"$api_key"'</api_key>\
      <alert_format>json</alert_format>\
    </integration>' "$config_file"
}

function restart_service(){
  systemctl restart wazuh-manager
  if [ $? -eq 0 ]; then
    echo "- Thehive: Serviço iniciado"
  else
    echo "- Thehive: Erro ao iniciar o serviço"
    exit 700
  fi
}

if [ "$(id -u)" != "0" ]; then
    echo "Este script deve ser executado como root."
    exit 1
else
    instal_thehive4py
    config_wserver_inter
    conf_api
    restart_service
fi

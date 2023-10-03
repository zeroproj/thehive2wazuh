# ERRO 300
#!/bin/bash
install_dir="/opt/MHSOC/"
domain_name=""
function install_nginx() {
    echo -e "- Instalando Pacotes Nginx e Snapd"
    apt remove certbot -y
    apt remove --purge nginx* -y
    apt install nginx snapd -y
    if [ $? -eq 0 ]; then
        echo "- Nginx: Instalado com sucesso"
        snap install core; snap refresh core
    else
        echo "- Nginx: Erro ao instalar o Certbot"
        exit 500
    fi
    snap install --classic certbot
    if [ $? -eq 0 ]; then
        echo "- Certbot: Instalado com sucesso"
    else
        echo "- Certbot: Erro ao instalar o Certbot"
        exit 500
    fi
}
function conf_nginx() {
    unlink /etc/nginx/sites-enabled/default
    read -p "Digite o nome de domínio para o servidor: " domain_name
    if [ -z "$domain_name" ]; then
        echo "O nome de domínio não pode estar em branco."
        exit 500
    fi

    ###############################CONFIG CERT######################################################

    ssl_certificate="/etc/letsencrypt/live/$domain_name/fullchain.pem" # managed by Certbot
    ssl_certificate_key="/etc/letsencrypt/live/$domain_name/privkey.pem" # managed by Certbot

    # Conteúdo do arquivo de configuração Nginx
    config_content="server {
        listen 80 default_server;
        server_name $domain_name;

        location / {
            proxy_pass https://127.0.0.1:4433;
            proxy_set_header Host \$host;
        }
    }
    "
    config_content_thehive="server {
    listen 9000 ssl; # Porta 9000
    server_name $domain_name;

    ssl on;
    ssl_certificate       $ssl_certificate;
    ssl_certificate_key   $ssl_certificate_key;

    proxy_connect_timeout   600;
    proxy_send_timeout      600;
    proxy_read_timeout      600;
    send_timeout            600;
    client_max_body_size    2G;
    proxy_buffering off;
    client_header_buffer_size 8k;

    location / {
        add_header Strict-Transport-Security 'max-age=31536000; includeSubDomains';
        proxy_pass http://127.0.0.1:9000;
        proxy_http_version      1.1;
    }
    }
    "
}

function conf_cert_arq_wserver(){
    arquivo_config="/etc/nginx/conf.d/wazuh.conf"
    echo "$config_content" | sudo tee "$arquivo_config" > /dev/null
    if [ $? -eq 0 ]; then
        echo "Arquivo de configuração Wazuh criado em $arquivo_config"
    else
        echo "Erro ao criar o arquivo de configuração Wazuh."
        exit 500
    fi
}

function conf_cert_arq_thehive(){
    arquivo_config_thehive="/etc/nginx/conf.d/thehive.conf"
    echo "$config_content_thehive" | sudo tee "$arquivo_config_thehive" > /dev/null
    if [ $? -eq 0 ]; then
        echo "Arquivo de configuração Wazuh criado em $arquivo_config_thehive"
    else
        echo "Erro ao criar o arquivo de configuração Wazuh."
        exit 500
    fi
}

function limpezaconf(){
    rm /etc/nginx/conf.d/thehive.conf
    rm /etc/nginx/conf.d/wazuh.conf
    #Padrão TheHive
    sed -i '/http\.port/d' $install_dir'MHConf/application.conf'
    sed -i '/http\.address/d' $install_dir'MHConf/application.conf'
    #Padrão Kibana
    sed -i "s/server.port: 4433/server.port: 443/g" $install_dir'MHConf/kibana.yml'
    sed -i "s/server.host: 127.0.0.1/server.host: 0.0.0.0/g" $install_dir'MHConf/kibana.yml'
}

function config_cert() {
    certbot --nginx -d $domain_name
    if [ $? -eq 0 ]; then
        echo "Certificado criado para o dominio $domain_name"
        sed -i "s/server.port: 443/server.port: 4433/g" $install_dir'MHConf/kibana.yml'
        sed -i "s/server.host: 0.0.0.0/server.host: 127.0.0.1/g" $install_dir'MHConf/kibana.yml'
        sed -i '$ahttp.port = 9000' $install_dir'MHConf/application.conf'
        sed -i '$ahttp.address = "127.0.0.1"' $install_dir'MHConf/application.conf'
        systemctl restart kibana
        systemctl restart thehive
    else
        rm /etc/nginx/conf.d/thehive.conf
        rm /etc/nginx/conf.d/wazuh.conf
        echo "Erro ao criar o arquivo de configuração Nginx."
        exit 500
    fi
}
function start_nginx() {
    systemctl restart nginx
    if [ $? -eq 0 ]; then
        echo "- Nginx: Configurado com Sucesso."
    else
        echo "- Nginx: Falha "
        limpezaconf
        systemctl restart kibana
        systemctl restart thehive
        exit 500
    fi
}

if [ "$(id -u)" != "0" ]; then
    echo "Este script deve ser executado como root."
    exit 1
else
    install_nginx #Install Nginx
    conf_nginx #Conf Nginx
    start_nginx #Iniciando Nginx
    limpezaconf # Removendo outras conf.
    conf_cert_arq_wserver #Configurando Arq Cert TheHive
    config_cert # Gerando Certificado
    #####Bloco de Conf de outras tecnoclogia####
    conf_cert_arq_thehive #Configurando Arq Cert TheHive
    ############################################
    start_nginx

fi
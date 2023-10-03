clear
if [ "$(id -u)" != "0" ]; then
    whiptail --title "Autentificação requerida" --msgbox "Este script requer privilégios de administrador. Execute-o como root." 12 50
    exit 1
fi
dic_temp=/opt/MHSOC/
choice=$(whiptail --title "MHSOC" --menu "BRSOC - ASSITENTE DE CONFIGURACAO" 12 50 4 \
    "1" "Instalação BRSOC" \
    "2" "Instalacão TheHive" \
    "3" "Instalacão Certificado Let's Encrypt" \
    "0" "Cancelar a instalação" 3>&1 1>&2 2>&3)
case $choice in
    1)
        echo "
        ██████╗ ██████╗ ███████╗ ██████╗  ██████╗
        ██╔══██╗██╔══██╗██╔════╝██╔═══██╗██╔════╝
        ██████╔╝██████╔╝███████╗██║   ██║██║     
        ██╔══██╗██╔══██╗╚════██║██║   ██║██║     
        ██████╔╝██║  ██║███████║╚██████╔╝╚██████╗
        ╚═════╝ ╚═╝  ╚═╝╚══════╝ ╚═════╝  ╚═════╝
        
        INSTALACAO E CONFIGURACAO
        "
        bash $dic_temp'MHSys/dep.sh' "-a"
        if [ $? -eq 0 ]; then
            echo "O script Elastic foi concluído com sucesso."
        else
            whiptail --title "Instalação Falhou" --msgbox "A instalação não foi concluída. Código de saída: $?" 12 50
            exit 0
        fi
        $dic_temp'MHSys/elastic.sh'
        if [ $? -eq 0 ]; then
            echo "O script Elastic foi concluído com sucesso."
        else
            whiptail --title "Instalação Falhou" --msgbox "A instalação não foi concluída. Código de saída: $?" 12 50
            exit 0
        fi
        $dic_temp'MHSys/wserver.sh'
        if [ $? -eq 0 ]; then
            echo "O script Elastic foi concluído com sucesso."
        else
            whiptail --title "Instalação Falhou" --msgbox "A instalação não foi concluída. Código de saída: $?" 12 50
            exit 0
        fi
        $dic_temp'MHSys/filebeat.sh'
        if [ $? -eq 0 ]; then
            echo "O script Elastic foi concluído com sucesso."
        else
            whiptail --title "Instalação Falhou" --msgbox "A instalação não foi concluída. Código de saída: $?" 12 50
            exit 0
        fi
        $dic_temp'MHSys/kibana.sh'
        if [ $? -eq 0 ]; then
            echo "O script Elastic foi concluído com sucesso."
        else
            whiptail --title "Instalação Falhou" --msgbox "A instalação não foi concluída. Código de saída: $?" 12 50
            exit 0
        fi
        ;;
    2)
        $dic_temp'MHSys/thehiveP1.sh'
        if [ $? -eq 0 ]; then
            echo "Instalacão Certificado Let's Encrypt foi concluída com sucesso."
        else
            whiptail --title "Instalação Falhou" --msgbox "A instalação não foi concluída. Código de saída: $?" 12 50
            exit 0
        fi
        ;;
    3)
        $dic_temp'MHSys/nginx.sh'
        if [ $? -eq 0 ]; then
            echo "Instalacão Certificado Let's Encrypt foi concluída com sucesso."
        else
            whiptail --title "Instalação Falhou" --msgbox "A instalação não foi concluída. Código de saída: $?" 12 50
            exit 0
        fi
        ;;
    0)
        whiptail --title "Instalação Cancelada" --msgbox "A instalação foi cancelada." 12 50
        exit 0
        ;;
    *)
        whiptail --title "Escolha Inválida" --msgbox "Escolha inválida. A instalação foi cancelada." 12 50
        exit 1
        ;;
esac
#if [ $? -eq 0 ]; then
#    echo "O script dep.sh foi concluído com sucesso."
#else
#    echo "O script dep.sh falhou. Código de saída: $?"
#fi
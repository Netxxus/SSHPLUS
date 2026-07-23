#!/bin/bash
FECHA=$(date +"%Y-%m-%d")
cor1='\033[1;31m'
cor2='\033[0;34m'
cor3='\033[1;35m'
clear
scor='\033[0m'
echo -e "\E[41;1;37m       NETXXUS   PYTHON3   MENU 🐲🏴      \E[0m"
echo -e "  [\033[1;31m1:\033[1;37m] \033[1;37m• \033[1;31m INSTALAR PYTHON3  \033[1;37m"
echo -e "  [\033[1;31m2:\033[1;37m] \033[1;37m• \033[1;31mVERIFICAR PYTHON3 \033[1;37m    "
echo -e "   [\033[1;31m3:\033[1;37m] \033[1;37m• \033[1;31mABRIR PYTHON3 \033[1;37m      \E[0m"

#leemos del teclado sentado
read n

case $n in
        1) clear
wget https://raw.githubusercontent.com/vpsvip7/VPS-AGN/main/installer/web1.sh && chmod +x web1.sh && ./web1.sh
            echo -ne "\n\033[1;31mListo \033[1;37mPython3 ok  \033[1;31mInstalado! 🐲🏴\033[0m"; read
           ;;
        2) clear
        netstat -tnpl
           echo -ne "\n\033[1;31mListo \033[1;37mPuertos Activos  \033[1;31mOK! 🐲🏴\033[0m"; read
            ;;
        3) clear
            websocket menu
             sleep 6
           ;;
        
        *) echo "Opción Incorrecta";;
esac

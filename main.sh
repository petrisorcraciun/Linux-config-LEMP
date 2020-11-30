clear

# Color Reset
Color_Off='\033[0m'       # Reset

# Regular Colors
Red='\033[0;31m'          # Red
Green='\033[0;32m'        # Green
Yellow='\033[0;33m'       # Yellow
Blue='\033[0;34m'         # Blue
Purple='\033[0;35m'       # Purple
Cyan='\033[0;36m'         # Cyan


line(){
echo "-----------------------------------------"
}

messageTop(){
echo -e "${Yellow}Info: ${Color_Off}"
line
echo "$(lsb_release -a)"
line
echo -e "Start: \t\t$(uptime -s)"
echo -e "Uptime: \t$(uptime -p)"
line
echo -e "CPU name: \t$(lscpu | sed -nr '/Model name/ s/.*:\s*(.*) @ .*/\1/p')"
echo -e "Architecture: \t$(uname -m)"
echo -e "Cores: \t\t$(nproc)"
echo -e "CPU MHz: \t$(lscpu | egrep "^CPU MHz:" | sed -e "s/[^0-9].[^0-9]//g")"

free -m | awk 'NR==2{printf "Memory Usage: \t%s/%sMB (%.2f%%)\n", $3,$2,$3*100/$2 }'
df -h | awk '$NF=="/"{printf "Disk Usage: \t%d/%dGB (%s)\n", $3,$2,$5}'


line
}


statusServices(){


if systemctl --type=service --state=active --state=inactive --state=running | grep -Fq 'php'; then
    echo 'PHP version $(php -v)'
else
    echo -e 'PHP: \t\tis not installed.'
fi

if systemctl --type=service --state=active --state=inactive --state=running | grep -Fq 'nginx'; then
    echo -e "Nginx: \t\t$(systemctl show -p ActiveState --value nginx)"
else
    echo 'Nginx is not installed.'
fi

if systemctl --type=service --state=active --state=inactive --state=running | grep -Fq 'mariadb'; then
    echo -e "MariaDB: \t$(systemctl show -p ActiveState --value mariadb)"
else
    echo 'MariaDB is not installed.'
fi

line
}

messageTop
statusServices       

if type lsb_release >/dev/null 2>&1 ; then
   distro=$(lsb_release -i -s)
elif [ -e /etc/os-release ] ; then
   distro=$(awk -F= '$1 == "ID" {print $2}' /etc/os-release)
elif [ -e /etc/some-other-release-file ] ; then
   distro=$(ihavenfihowtohandleotherhypotheticalreleasefiles)
fi

# convert to lowercase
distro=$(printf '%s\n' "$distro" | LC_ALL=C tr '[:upper:]' '[:lower:]')


updateDebian(){
        apt-get update
}

installNginx(){
        apt install nginx
}

messageNginx(){
        echo -e "${Green}Is installed version ${Color_Off} $(nginx -v)"
}

if [[ $EUID -ne 0 ]]; then
   echo -e "${Red}For more options you must be root...${Color_Off}"

else

case "$distro" in
        debian*) echo ""; updateDebian installNginx messageNginx;;
        *) echo "unknown distro"; exit 1;;
esac



exit 1
fi

line


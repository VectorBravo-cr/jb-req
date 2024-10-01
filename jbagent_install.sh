#!/bin/sh
shopt -s extglob #странная конструкция, но работает

# This script installs jb-agent on Linux or MacOS.
# It detects the current operating system architecture and installs the appropriate version.
#####################################################
#                     переменные                    #
##################################################### 

ACTUAL_VERSION="2024.9.9"

current_version_jb="$JB_AGENT_VERSION"
current_direction_jb="$JB_AGENT_DIRECTORY"

OS=$(uname)
BASE_INSTALL="true"

BASE_PATH=$(dirname $(
  cd $(dirname "$0")
  pwd
))

status() { echo ">>> $*" >&2; }
error() { echo "ERROR $* Installation stoped. Check log and fix errors"; exit 1; }
warning() { echo "WARNING: $*"; }
available() { command -v $1 >/dev/null; }

require() {
    local MISSING=''
    for TOOL in $*; do
        if ! available $TOOL; then
            MISSING="$MISSING $TOOL"
        fi
    done

    echo $MISSING
}

function pre_show_welcome () {
    
    cat << "EOF"
██╗    ██╗███████╗██╗      ██████╗ ██████╗ ███╗   ███╗███████╗                          
██║    ██║██╔════╝██║     ██╔════╝██╔═══██╗████╗ ████║██╔════╝                          
██║ █╗ ██║█████╗  ██║     ██║     ██║   ██║██╔████╔██║█████╗                            
██║███╗██║██╔══╝  ██║     ██║     ██║   ██║██║╚██╔╝██║██╔══╝                            
╚███╔███╔╝███████╗███████╗╚██████╗╚██████╔╝██║ ╚═╝ ██║███████╗                          
 ╚══╝╚══╝ ╚══════╝╚══════╝ ╚═════╝ ╚═════╝ ╚═╝     ╚═╝╚══════╝                          
                                                                                        
████████╗ ██████╗          ██╗██████╗        █████╗  ██████╗ ███████╗███╗   ██╗████████╗
╚══██╔══╝██╔═══██╗         ██║██╔══██╗      ██╔══██╗██╔════╝ ██╔════╝████╗  ██║╚══██╔══╝
   ██║   ██║   ██║         ██║██████╔╝█████╗███████║██║  ███╗█████╗  ██╔██╗ ██║   ██║   
   ██║   ██║   ██║    ██   ██║██╔══██╗╚════╝██╔══██║██║   ██║██╔══╝  ██║╚██╗██║   ██║   
   ██║   ╚██████╔╝    ╚█████╔╝██████╔╝      ██║  ██║╚██████╔╝███████╗██║ ╚████║   ██║   
   ╚═╝    ╚═════╝      ╚════╝ ╚═════╝       ╚═╝  ╚═╝ ╚═════╝ ╚══════╝╚═╝  ╚═══╝   ╚═╝   
                                                                                        
██╗███╗   ██╗███████╗████████╗ █████╗ ██╗     ██╗     ███████╗██████╗                   
██║████╗  ██║██╔════╝╚══██╔══╝██╔══██╗██║     ██║     ██╔════╝██╔══██╗                  
██║██╔██╗ ██║███████╗   ██║   ███████║██║     ██║     █████╗  ██████╔╝                  
██║██║╚██╗██║╚════██║   ██║   ██╔══██║██║     ██║     ██╔══╝  ██╔══██╗                  
██║██║ ╚████║███████║   ██║   ██║  ██║███████╗███████╗███████╗██║  ██║                  
╚═╝╚═╝  ╚═══╝╚══════╝   ╚═╝   ╚═╝  ╚═╝╚══════╝╚══════╝╚══════╝╚═╝  ╚═╝                                                                                                       

Welcome to installer/upgrader JB_Packages_installer v$ACTUAL_VERSION  
Default script created for 
■ Debian
■ Ubuntu
■ Mint
■ Fedora
■ Arch
■ MacOS

Default installation include options: 
■ Installin/Upgradin jb-agent
■ Installin JB-Ide's (optional)
■ Uninstalling jb-agent
EOF
}

function get_curl_vers () {
    _version=$(curl -s https://raw.githubusercontent.com/VectorBravo-cr/jb-req/refs/heads/main/dependencies.json | jq -r ".version")
    ACTUAL_VERSION=$_version
    echo "Actual response version $ACTUAL_VERSION"
}

function get_file_vers () {
    cd ~/.jb-agent/
    cd $current_direction_jb
    version=$(ls -al | grep jb-agent* | sed 's/.*_\(.*\)\.tar\.gz/\1/')
    current_version_jb=$version
    # echo "searching echo $current_version_jb"
}

function check_version () {
    # two methods checking
    get_curl_vers
    get_file_vers

    if [[ "$current_version_jb" != "$ACTUAL_VERSION" ]]; then
            return
        else
            echo "Your version is up to date ($ACTUAL_VERSION)."
            echo "Installation cancelled"
            echo "  "
            deleter
            exit 1
        fi
}


function check_installed_version () {
    directory=$current_direction_jb
    if [ -z "$directory" ]; then
        directory=$HOME/.jb-agent/
    fi
    echo " "
    if [ -d "$directory" ]; then
        echo "Dir $directory is exist. Check version."
        check_version
        return
    else
        # echo "Dir $directory is not exist. Start install."
        return
    fi
}

function installation_interactive_menu () {

    echo " "
    read -p "Ypu want to install JetBrains Agent? (y/n):" response
    if [ "$response" != "y" ]; then
        echo "Installation cancelled"
        exit 1
    fi
}

function base_direction_interactive_menu () {
    echo "Specify the installation directory path [defautl: $HOME/.jb-agent/]:"
    read install_dir
    if [ -z "$install_dir" ];
    then
        install_dir=$HOME/.jb-agent/
    fi
    echo "The selected installation path: $install_dir"

}

function post_show_install () {
    cat << "EOF"
Installation jb-agent successfully
You need:
■ Reboot your system (or re-login)
■ Insert Activation Code in IDE (choose: show or copy)
■ onLink: https://raw.githubusercontent.com/VectorBravo-cr/jb-req/refs/heads/main/dependencies.json
■ Activation code: 
'A8V8N88K9P-eyJsaWNlbnNlSWQiOiJBOFY4Tjg4SzlQIiwibGljZW5zZWVOYW1lIjoi0JDQniDCq9Cf0KQgwqvQodCa0JEg0JrQvtC90YLRg9GAwrsiLCJhc3NpZ25lZU5hbWUiOiJ0ZXN0ZXIiLCJhc3NpZ25lZUVtYWlsIjoiIiwibGljZW5zZVJlc3RyaWN0aW9uIjoiIiwiY2hlY2tDb25jdXJyZW50VXNlIjpmYWxzZSwicHJvZHVjdHMiOlt7ImNvZGUiOiJJVSIsImZhbGxiYWNrRGF0ZSI6IjIwMjQtMTItMzEiLCJwYWlkVXBUbyI6IjIwMjQtMTItMzEiLCJleHRlbmRlZCI6ZmFsc2V9LHsiY29kZSI6IklDIiwiZmFsbGJhY2tEYXRlIjoiMjAyNC0xMi0zMSIsInBhaWRVcFRvIjoiMjAyNC0xMi0zMSIsImV4dGVuZGVkIjpmYWxzZX0seyJjb2RlIjoiSUUiLCJmYWxsYmFja0RhdGUiOiIyMDI0LTEyLTMxIiwicGFpZFVwVG8iOiIyMDI0LTEyLTMxIiwiZXh0ZW5kZWQiOmZhbHNlfSx7ImNvZGUiOiJQUyIsImZhbGxiYWNrRGF0ZSI6IjIwMjQtMTItMzEiLCJwYWlkVXBUbyI6IjIwMjQtMTItMzEiLCJleHRlbmRlZCI6ZmFsc2V9LHsiY29kZSI6IldTIiwiZmFsbGJhY2tEYXRlIjoiMjAyNC0xMi0zMSIsInBhaWRVcFRvIjoiMjAyNC0xMi0zMSIsImV4dGVuZGVkIjpmYWxzZX0seyJjb2RlIjoiUFkiLCJmYWxsYmFja0RhdGUiOiIyMDI0LTEyLTMxIiwicGFpZFVwVG8iOiIyMDI0LTEyLTMxIiwiZXh0ZW5kZWQiOmZhbHNlfSx7ImNvZGUiOiJQQyIsImZhbGxiYWNrRGF0ZSI6IjIwMjQtMTItMzEiLCJwYWlkVXBUbyI6IjIwMjQtMTItMzEiLCJleHRlbmRlZCI6ZmFsc2V9LHsiY29kZSI6IlBFIiwiZmFsbGJhY2tEYXRlIjoiMjAyNC0xMi0zMSIsInBhaWRVcFRvIjoiMjAyNC0xMi0zMSIsImV4dGVuZGVkIjpmYWxzZX0seyJjb2RlIjoiUk0iLCJmYWxsYmFja0RhdGUiOiIyMDI0LTEyLTMxIiwicGFpZFVwVG8iOiIyMDI0LTEyLTMxIiwiZXh0ZW5kZWQiOmZhbHNlfSx7ImNvZGUiOiJPQyIsImZhbGxiYWNrRGF0ZSI6IjIwMjQtMTItMzEiLCJwYWlkVXBUbyI6IjIwMjQtMTItMzEiLCJleHRlbmRlZCI6ZmFsc2V9LHsiY29kZSI6IkNMIiwiZmFsbGJhY2tEYXRlIjoiMjAyNC0xMi0zMSIsInBhaWRVcFRvIjoiMjAyNC0xMi0zMSIsImV4dGVuZGVkIjpmYWxzZX0seyJjb2RlIjoiR08iLCJmYWxsYmFja0RhdGUiOiIyMDI0LTEyLTMxIiwicGFpZFVwVG8iOiIyMDI0LTEyLTMxIiwiZXh0ZW5kZWQiOmZhbHNlfSx7ImNvZGUiOiJEQiIsImZhbGxiYWNrRGF0ZSI6IjIwMjQtMTItMzEiLCJwYWlkVXBUbyI6IjIwMjQtMTItMzEiLCJleHRlbmRlZCI6ZmFsc2V9LHsiY29kZSI6IkRTIiwiZmFsbGJhY2tEYXRlIjoiMjAyNC0xMi0zMSIsInBhaWRVcFRvIjoiMjAyNC0xMi0zMSIsImV4dGVuZGVkIjpmYWxzZX0seyJjb2RlIjoiREIiLCJmYWxsYmFja0RhdGUiOiIyMDI0LTEyLTMxIiwicGFpZFVwVG8iOiIyMDI0LTEyLTMxIiwiZXh0ZW5kZWQiOmZhbHNlfSx7ImNvZGUiOiJEQyIsImZhbGxiYWNrRGF0ZSI6IjIwMjQtMTItMzEiLCJwYWlkVXBUbyI6IjIwMjQtMTItMzEiLCJleHRlbmRlZCI6ZmFsc2V9LHsiY29kZSI6IkRCIiwiZmFsbGJhY2tEYXRlIjoiMjAyNC0xMi0zMSIsInBhaWRVcFRvIjoiMjAyNC0xMi0zMSIsImV4dGVuZGVkIjpmYWxzZX0seyJjb2RlIjoiUERCIiwiZmFsbGJhY2tEYXRlIjoiMjAyNC0xMi0zMSIsInBhaWRVcFRvIjoiMjAyNC0xMi0zMSIsImV4dGVuZGVkIjpmYWxzZX0seyJjb2RlIjoiREIiLCJmYWxsYmFja0RhdGUiOiIyMDI0LTEyLTMxIiwicGFpZFVwVG8iOiIyMDI0LTEyLTMxIiwiZXh0ZW5kZWQiOmZhbHNlfSx7ImNvZGUiOiJQU0kiLCJmYWxsYmFja0RhdGUiOiIyMDI0LTEyLTMxIiwicGFpZFVwVG8iOiIyMDI0LTEyLTMxIiwiZXh0ZW5kZWQiOmZhbHNlfSx7ImNvZGUiOiJEQiIsImZhbGxiYWNrRGF0ZSI6IjIwMjQtMTItMzEiLCJwYWlkVXBUbyI6IjIwMjQtMTItMzEiLCJleHRlbmRlZCI6ZmFsc2V9LHsiY29kZSI6IkRQIiwiZmFsbGJhY2tEYXRlIjoiMjAyNC0xMi0zMSIsInBhaWRVcFRvIjoiMjAyNC0xMi0zMSIsImV4dGVuZGVkIjpmYWxzZX0seyJjb2RlIjoiREIiLCJmYWxsYmFja0RhdGUiOiIyMDI0LTEyLTMxIiwicGFpZFVwVG8iOiIyMDI0LTEyLTMxIiwiZXh0ZW5kZWQiOmZhbHNlfSx7ImNvZGUiOiJEUE4iLCJmYWxsYmFja0RhdGUiOiIyMDI0LTEyLTMxIiwicGFpZFVwVG8iOiIyMDI0LTEyLTMxIiwiZXh0ZW5kZWQiOmZhbHNlfSx7ImNvZGUiOiJEQiIsImZhbGxiYWNrRGF0ZSI6IjIwMjQtMTItMzEiLCJwYWlkVXBUbyI6IjIwMjQtMTItMzEiLCJleHRlbmRlZCI6ZmFsc2V9LHsiY29kZSI6IkRNIiwiZmFsbGJhY2tEYXRlIjoiMjAyNC0xMi0zMSIsInBhaWRVcFRvIjoiMjAyNC0xMi0zMSIsImV4dGVuZGVkIjpmYWxzZX0seyJjb2RlIjoiREIiLCJmYWxsYmFja0RhdGUiOiIyMDI0LTEyLTMxIiwicGFpZFVwVG8iOiIyMDI0LTEyLTMxIiwiZXh0ZW5kZWQiOmZhbHNlfSx7ImNvZGUiOiJSRCIsImZhbGxiYWNrRGF0ZSI6IjIwMjQtMTItMzEiLCJwYWlkVXBUbyI6IjIwMjQtMTItMzEiLCJleHRlbmRlZCI6ZmFsc2V9LHsiY29kZSI6IkFJIiwiZmFsbGJhY2tEYXRlIjoiMjAyNC0xMi0zMSIsInBhaWRVcFRvIjoiMjAyNC0xMi0zMSIsImV4dGVuZGVkIjpmYWxzZX1dLCJtZXRhZGF0YSI6IjAxMjAyMzAxMDJQUEFBMDEzMDA5IiwiaGFzaCI6IjQxNDcyOTYxLzA6MTU2MzYwOTQ1MSIsImdyYWNlUGVyaW9kRGF5cyI6NywiYXV0b1Byb2xvbmdhdGVkIjp0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'
EOF
    
}

function check_root () {
    SUDO=
        if [ "$(id -u)" -ne 0 ]; then
            # Running as root, no need for sudo
            if ! available sudo; then
                echo "This script requires superuser permissions. Please re-run as root."
            fi

            SUDO="sudo"
        fi

}

function check_dependens () {

    NEEDS=$(require curl wget jq awk grep sed tee xargs)
        if [ -n "$NEEDS" ]; then
            status "ERROR: The following tools are required but missing:"
            for NEED in $NEEDS; do
                echo "  - $NEED"
                
            done
            exit 1
        fi

}

function pre_setup_script () {
    rm -f /tmp/jbt_install.log
    exec > >(tee /tmp/jbt_install.log)
    echo "error" >&2
    echo "notice" >&2

    export LC_ALL=en_US.utf-8
    export LANG=en_US.utf-8
}

# deparcted
# function get_external_credentials {
#     local vault_subpath=$1 #/save_pass/jb_script/
#     local extracted_field=$2
    
#     local vault_login=$kats_updater_login
#     local vault_password=$kats_updater_password
    

#     token=$(curl -s -X POST -d "{\"password\": \"$vault_password\"}" https://vault.skbkontur.ru/v1/auth/ldap/login/$vault_login | jq ".auth.client_token" | tr -d '"')
#     responce=$(curl -s -X GET -H "X-Vault-Token: $token" "https://vault.skbkontur.ru/v1/secret/data/otss/$vault_subpath")
#     if [ -z $extracted_field ]; then
#         echo $responce;
#     else
#         responce=$(echo $responce | jq "$extracted_field")
#         echo $responce;
#     fi
# }

function unpuck_agent () {
    NAME_DIS=$1
    mkdir tmp_unpuck_agent
    CURRENT_DIR=$(pwd)
    tar -xzf $NAME_DIS -C 'tmp_unpuck_agent'
    if [ $? -eq 0 ];
    then
        echo "Archive has been successfully extracted to the directory $CURRENT_DIR/tmp_unpuck_agent"
    else
        echo "Error occurred during the extraction of the archive."
    fi
}

function get_package_jb_agent () {
    URL=$1
    CURRENT_DIR=$(pwd)
    OUTPUT_FILE=$(echo "$URL" | awk -F'files=' '{print $2}')
    wget "$URL" -O "$OUTPUT_FILE" &
    # sleep 2
    wait $!

    if [ $? -eq 0 ];
    then
        echo "The client has been successfully downloaded. Unpacking now."
        unpuck_agent $OUTPUT_FILE
        
        version=$(echo "$URL" | sed 's/.*_\(.*\)\.tar\.gz/\1/')
        echo "Selected version = $version"
        echo "local direction version = $CURRENT_DIR"
        echo $(ls -al)
        export JB_AGENT_VERSION="$version"
        export JB_AGENT_DIRECTORY="$CURRENT_DIR"
    else
        error() { echo "ERROR $* Installation stoped. Check log and fix errors"; exit 1; }
    fi
}

function create_dir_install () {
    if [ -d "$install_dir" ];
    then
        echo "Direction exist"
        cd $install_dir
        export JB_AGENT_DIRECTORY="$(pwd)"
    else
        mkdir $install_dir
        echo "Create direction $install_dir"
        cd $install_dir
        export JB_AGENT_DIRECTORY="$(pwd)"
    fi
}

function profile_env_setter () {
    
    if [ $OS == "Darwin" ]; then
        profile_file=~/.bash_profile
        echo "export JB_AGENT_DIRECTORY=$JB_AGENT_DIRECTORY" >> $profile_file
        echo "export JB_AGENT_VERSION=$JB_AGENT_VERSION" >> $profile_file
    else
        profile_file=~/.bashrc
        echo "JB_AGENT_DIRECTORY=$JB_AGENT_DIRECTORY" >> $profile_file
        echo "JB_AGENT_VERSION=$JB_AGENT_VERSION" >> $profile_file
    fi

    
    echo "Enviroment sett JB_AGENT_DIRECTORY JB_AGENT_VERSION."
    source $profile_file
}

function install_starter () {
    cd $JB_AGENT_DIRECTORY/tmp_unpuck_agent/
    echo $(pwd)
    ./scripts/install.sh
    cd $JB_AGENT_DIRECTORY
}

function installer () {
    if [[ $OS == "Linux" ]]; then
        echo "Install to Linux"
        create_dir_install
        get_package_jb_agent 'https://disk.skbkontur.ru/index.php/s/JazZcznaDoSw2YS/download?path=%2F&files=jb-agent_2024.9.9.tar.gz'
        
    elif [[ $OS == "Darwin" ]]; then
        echo "Install to MacOS"
        create_dir_install
        get_package_jb_agent 'https://disk.skbkontur.ru/index.php/s/HBZtG6SxAHxaCzd/download?path=%2F&files=jb-agent_2024.9.9.tar.gz'

    else
        echo "Неизвестная операционная система. Обратитесь в поддержку."
        exit 1
fi

    install_starter
    profile_env_setter
    post_show_install
}

function deleter () {
    echo " "
    read -p "You want to delete JetBrains Agent? (y/n):" response
    if [ "$response" != "y" ]; then
        exit 1
    else
        source $JB_AGENT_DIRECTORY/tmp_unpuck_agent/scripts/uninstall.sh
        rm -rf $JB_AGENT_DIRECTORY/tmp_unpuck_agent/
        rm -rf $JB_AGENT_DIRECTORY

        # unset $JB_AGENT_DIRECTORY
        # unset $JB_AGENT_VERSION
       
        if [ $OS == "Darwin" ]; then
            profile_file=~/.bash_profile
        else
            profile_file=~/.bashrc
        fi
       
        sed -i '/export JB_AGENT_DIRECTORY=/d' $profile_file
        sed -i '/export JB_AGENT_VERSION=/d' $profile_file
    fi

}

#######################################################
#######################################################
##  конец области функций, начало исполняемого кода  ##
#######################################################
#######################################################

# get_file_vers

pre_setup_script # log enabled
pre_show_welcome # text hello

check_installed_version # checker and runner deleter

installation_interactive_menu # check install or update or delete 
check_dependens
base_direction_interactive_menu # if install - select dir
# check_root deprecated

installer

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
'code in this'
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

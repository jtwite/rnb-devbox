#!/bin/bash

# Color variables
red='\033[0;31m'
green='\033[0;32m'
yellow='\033[0;33m'
blue='\033[0;34m'
magenta='\033[0;35m'
cyan='\033[0;36m'
# Clear the color after that
clear='\033[0m'

echoDate() {
	echo -e "${cyan}`date -u`${clear}: $1"
}

rnbDir=$HOME/rnb-system
userJavaDir="$HOME/rnb-system/java"

mkdir -p $userJavaDir

if [[ -z "${NIX_JAVA_DIR}" ]]; then
	NIX_JAVA_DIR="/nix/store/$(ls /nix/store/ | grep -e ".*temurin.*[0-9\.]$" | tail -1)"
elif [[ -z "$NIX_JAVA_DIR" ]]; then
	NIX_JAVA_DIR="/nix/store/$(ls /nix/store/ | grep -e ".*temurin.*[0-9\.]$" | tail -1)"
fi
rsync -a -k --chmod=777 $NIX_JAVA_DIR/* $userJavaDir
echoDate " - devbox java is installed here: $NIX_JAVA_DIR"

profileJavaHomeCount=$(cat ~/.profile | grep "JAVA_HOME" | wc -l | sed 's/[[:space:]]*//g')
bashrcJavaHomeCount=$(cat ~/.bashrc | grep "JAVA_HOME" | wc -l | sed 's/[[:space:]]*//g')
zshrcJavaHomeCount=$(cat ~/.zshrc | grep "JAVA_HOME" | wc -l | sed 's/[[:space:]]*//g')
javaHomeString="export JAVA_HOME=\"$userJavaDir\""

if [[ $profileJavaHomeCount -eq 0 ]]; then
	echo -e "Adding JAVA_HOME to ~/.profile";
	echo -e $javaHomeString >> ~/.profile;
elif [[ $profileJavaHomeCount -eq 1 ]]; then
	sed -i -e "s/export JAVA_HOME=.*/export JAVA_HOME=\"${userJavaDir//\//\\/}\"/" ~/.profile
fi
if [[ $bashrcJavaHomeCount -eq 0 ]]; then
	echo -e "Adding JAVA_HOME to ~/.bashrc";
	echo -e $javaHomeString >> ~/.bashrc;
elif [[ $bashrcJavaHomeCount -eq 1 ]]; then
	sed -i -e "s/export JAVA_HOME=.*/export JAVA_HOME=\"${userJavaDir//\//\\/}\"/" ~/.bashrc
fi

if [[ $zshrcJavaHomeCount -eq 0 ]]; then
	echo -e "Adding JAVA_HOME to ~/.zshrc";
	echo -e $javaHomeString >> ~/.zshrc;
elif [[ $zshrcJavaHomeCount -eq 1 ]]; then
	sed -i -e "s/export JAVA_HOME=.*/export JAVA_HOME=\"${userJavaDir//\//\\/}\"/" ~/.zshrc
fi

source ~/.profile

echoDate " - Setting default branch to main"

defaultBranchInit="$(git config --global init.defaultBranch main)"

echoDate " - Verifying you have logged into docker server"
dockerLoggedIn=$(cat ~/.docker/config.json | grep dockerimages.roomandboard.com | wc -l | sed 's/[[:space:]]*//g')

if [[ $dockerLoggedIn -eq 0 ]]; then
	echoDate "You are not logged into docker server. Please login to docker server.  You can get the information from secret server."
	echoDate "The command is 'docker login dockerimages.roomandboard.com'"
fi

echoDate " - Verifying your /etc/hosts file configuration"
hostsFile=$(cat /etc/hosts | sed 's/[[:space:]]*//g')
configEntry=$(echo $hostsFile | grep configserver | wc -l | sed 's/[[:space:]]*//g')
webEntry=$(echo $hostsFile | grep web-service | wc -l | sed 's/[[:space:]]*//g')
engageEntry=$(echo $hostsFile | grep engage-service | wc -l | sed 's/[[:space:]]*//g')

if [[ $webEntry -eq 0 || $configEntry -eq 0 || $engageEntry -eq 0 ]]; then
	echoDate " - - Your /etc/hosts file is not configured properly. Please add the following entries to your /etc/hosts file"
	printf "127.0.0.1       configserver-service postgres-service mongo-service\n127.0.0.1       {host}.local {host}.roomandboard.com\n127.0.0
.1       engage{host} engage{host}.roomandboard.com \n127.0.0.1       web-service engage-service\n"
fi

echoDate " - Verifying the right certificate is in your java keystore"
certInKeystoreResult=$($userJavaDir/bin/keytool -v -list -cacerts -alias vmprdcrt01-ca)

if [ $? -eq 0 ]; then
	echoDate " - - The certificate is in your keystore"
else
	echoDate " - - The vmprdcrt01-ca certificate is not in your keystore. Please add the certificate to your java keystore"
	echoDate " - - Here is how to do just that:"
	echoDate " - - 1. Download the vmprodcrt01-ca.cer file from the secret server"
	echoDate " - - 2. Run the following command: $userJavaDir/bin/keytool -import -alias vmprdcrt01-ca -keystore $userJavaDir/lib/security/cacerts -file vmprdcrt01-ca.cer"
fi

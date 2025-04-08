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

echo $DEVBOX_PROJECT_ROOT;
bash $DEVBOX_PROJECT_ROOT/setup-env.sh;
echoDate "starting tomcat ${green}$CATALINA_HOME${clear}";
echoDate "Using JAVA_HOME: ${green}$JAVA_HOME${clear}";
echoDate "Where the files are going to be: ${green}$CATALINA_BASE${clear}";

NIX_CATALINA_HOME="/nix/store/$(ls /nix/store/ | grep -e '.*tomcat.*[0-9/.]$' | tail -1)";

echoDate "Syncing tomcat files from ${red}$NIX_CATALINA_HOME${clear} to ${green}$CATALINA_BASE${clear}";
# rsync -a -k --chmod=ugo=rwX --ignore-existing $NIX_CATALINA_HOME/* $CATALINA_BASE;

# ${CATALINA_HOME}/bin/catalina.sh run;

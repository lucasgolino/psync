#!/bin/bash
# shellcheck disable=SC2162

# Colors to output
BLACK=0
RED=1
GREEN=2
YELLOW=3
MAGENTA=5
BLUE=4
CYAN=6

RESET=$(tput sgr0)
TEXT_COLOR="tput setaf "
BACKGROUND_COLOR="tput setab "
CLEAR_UP="#tput cuu 1; tput ed;"

# Welcome colors
COLOR_FRAME=$($TEXT_COLOR $GREEN)
COLOR_P=$($TEXT_COLOR $YELLOW)
COLOR_TEXT=$($TEXT_COLOR $CYAN)

# Define variables for the installation
DEFAULT_PATH="/opt"
DEFAULT_FOLDER_NAME="psync"

function print_welcome() {
  echo "${COLOR_FRAME}.-----------------------------------------------------------------.";
  echo "${COLOR_FRAME}|${COLOR_P}      ___     ${COLOR_TEXT}     ___       ___          ___          ___       ${COLOR_FRAME}|";
  echo "${COLOR_FRAME}|${COLOR_P}     /\  \    ${COLOR_TEXT}    /\  \     |\__\        /\__\        /\  \      ${COLOR_FRAME}|";
  echo "${COLOR_FRAME}|${COLOR_P}    /::\  \   ${COLOR_TEXT}   /::\  \    |:|  |      /::|  |      /::\  \     ${COLOR_FRAME}|";
  echo "${COLOR_FRAME}|${COLOR_P}   /:/\:\  \  ${COLOR_TEXT}  /:/\ \  \   |:|  |     /:|:|  |     /:/\:\  \    ${COLOR_FRAME}|";
  echo "${COLOR_FRAME}|${COLOR_P}  /::\~\:\  \ ${COLOR_TEXT} _\:\~\ \  \  |:|__|__  /:/|:|  |__  /:/  \:\  \   ${COLOR_FRAME}|";
  echo "${COLOR_FRAME}|${COLOR_P} /:/\:\ \:\__\\${COLOR_TEXT}/\ \:\ \ \__\ /::::\__\/:/ |:| /\__\/:/__/ \:\__\  ${COLOR_FRAME}|";
  echo "${COLOR_FRAME}|${COLOR_P} \/__\:\/:/  /${COLOR_TEXT}\:\ \:\ \/__//:/~~/~   \/__|:|/:/  /\:\  \  \/__/  ${COLOR_FRAME}|";
  echo "${COLOR_FRAME}|${COLOR_P}      \::/  / ${COLOR_TEXT} \:\ \:\__\ /:/  /         |:/:/  /  \:\  \        ${COLOR_FRAME}|";
  echo "${COLOR_FRAME}|${COLOR_P}       \/__/  ${COLOR_TEXT}  \:\/:/  / \/__/          |::/  /    \:\  \       ${COLOR_FRAME}|";
  echo "${COLOR_FRAME}|${COLOR_P}              ${COLOR_TEXT}   \::/  /                 /:/  /      \:\__\      ${COLOR_FRAME}|";
  echo "${COLOR_FRAME}|${COLOR_P}              ${COLOR_TEXT}    \/__/                  \/__/        \/__/      ${COLOR_FRAME}|";
  echo "${COLOR_FRAME}˙-----------------------------------------------------------------˙";
  echo "${RESET}"
}

function acquire_env() {
  read -p "Now we gonna get the environment variables."
  read -p "Let's start with the Google Cloud credentials."

  read -p "> [Google Cloud] ProjectID: " project_id
  read -p "> [Google Cloud] Storage BucketName: " bucket_name
  read -p "> [Google Cloud] Application Credential Full file path: " service_account_file

  printf "\n"
  read -p "Now we gonna get the PostgreSQL credentials."
  read -p "> [PostgreSQL]: Host: " psql_host
  read -p "> [PostgreSQL]: Port: " psql_port
  read -p "> [PostgreSQL]: Database Name: " psql_db
  read -p "> [PostgreSQL]: Username: " psql_username
  read -s -p "> [PostgreSQL]: Password: " psql_password

  printf "\n\n"
  read -p "Now we gonna define psync settings."
  read -p "> [Settings]: Install Folder (keep it blank to use default: /opt): " install_folder_path
  read -p "> [Settings]: Start after installation? (y/N): " start_after_install

  printf "\n"
  read -p "Define cron time for the backup schedule."
  read -p  "Timer format if based on systemd timer onCalendar, for help: man systemd"

  read -p "> [Settings]: OnCalendar: " cron_time
}

function install_service() {
  local systemd_folder="/etc/systemd/system"

  cp ./assets/psync.service $systemd_folder
  cp ./assets/psync.timer $systemd_folder

  sed -i "s|iPSYNC_INSTALL_PATH|${install_path}|g" $systemd_folder/psync.service
  sed -i "s|iPSYNC_INSTALL_PATH|${install_path}|g" $systemd_folder/psync.service
  sed -i "s|iPSYNC_CRONTIME|${cron_time}|g" $systemd_folder/psync.timer

  systemctl enable psync.service &> /dev/null
  systemctl enable psync.timer &> /dev/null

  if [[ "$start_after_install" == "y" ]]; then
    systemctl start psync.timer &> /dev/null
    printf "pSYNC timer Started! \n"
  fi

  printf "Finish to install the service, you can check the status with: systemctl status psync.timer\n"
  printf "And for start a run this moment to check if everything is working you can use: systemctl start psync.service\n"
}

function install() {
  install_path="$install_folder_path/$DEFAULT_FOLDER_NAME"

  if [[ "$install_folder_path" == "" ]]; then
    install_path="$DEFAULT_PATH/$DEFAULT_FOLDER_NAME"
  fi

  mkdir -p $install_path

  cp ./assets/configuration.env $install_path

  sed -i "s|iREPLACE_CPATH|${service_account_file}|g" $install_path/configuration.env
  sed -i "s|iREPLACE_PID|${project_id}|g" $install_path/configuration.env
  sed -i "s|iREPLACE_BNAME|${bucket_name}|g" $install_path/configuration.env
  sed -i "s|iREPLACE_PHOST|${psql_host}|g" $install_path/configuration.env
  sed -i "s|iREPLACE_PPORT|${psql_port}|g" $install_path/configuration.env
  sed -i "s|iREPLACE_PDBNAME|${psql_db}|g" $install_path/configuration.env
  sed -i "s|iREPLACE_PUSER|${psql_username}|g" $install_path/configuration.env
  sed -i "s|iREPLACE_PPASS|${psql_password}|g" $install_path/configuration.env

  go build -o $install_path/psync ../cmd/main.go &> /dev/null
}

function main() {

  print_welcome

  printf "Welcome to the installation of the PSync tool. [PRESS ENTER TO START]\n\n"
  acquire_env
  install
  install_service
}


main
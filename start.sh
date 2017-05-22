#!/bin/bash
# this script must be run as root or with sudo

# find the directory containing this script
MY_SOURCE="${BASH_SOURCE[0]}"

# resolve $MY_SOURCE until the file is no longer a symlink
while [ -h "$MY_SOURCE" ]; do
  MY_DIR="$( cd -P "$( dirname "$MY_SOURCE" )" && pwd )"
  MY_SOURCE="$(readlink "$MY_SOURCE")"
  [[ $MY_SOURCE != /* ]] && MY_SOURCE="$MY_DIR/$MY_SOURCE" # if $MY_SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done

# deduce the directory path from MY_SOURCE
MY_DIR="$( cd -P "$( dirname "$MY_SOURCE" )" && pwd )"

# deduce the directory name from MY_SOURCE
MY_DIR_NAME=$(echo $MY_DIR | sed -e 's?.*/??')

# abort if any command fails or enviroment variable is not set properly
set -eu

# set up GALAXY_IDENTITY for this script and galaxy-compose.xml
GALAXY_IDENTITY=$(cat ${MY_DIR}/GALAXY_IDENTITY); export GALAXY_IDENTITY

# set up GALAXY_CONFIG_MASTER_API_KEY for galaxy-compose.xml
GALAXY_CONFIG_MASTER_API_KEY=$(cat ${MY_DIR}/API_KEY); export GALAXY_CONFIG_MASTER_API_KEY

# set up GALAXY_CONFIG_ADMIN_USERS for galaxy-compose.xml
GALAXY_CONFIG_ADMIN_USERS=$(cat ${MY_DIR}/GALAXY_CONFIG_ADMIN_USERS); export GALAXY_CONFIG_ADMIN_USERS

# set up EXPORT_PARENT_DIR for galaxy-compose.xml
EXPORT_PARENT_DIR=$(cat ${MY_DIR}/EXPORT_PARENT_DIR); export EXPORT_PARENT_DIR

# set up *_PORT* for galaxy-compose.xml
GALAXY_PORT_FTP=$(cat ${MY_DIR}/GALAXY_PORT_FTP);         export GALAXY_PORT_FTP
GALAXY_PORT_HTTP=$(cat ${MY_DIR}/GALAXY_PORT_HTTP);       export GALAXY_PORT_HTTP
ETHERCALC_PORT_CALC=$(cat ${MY_DIR}/ETHERCALC_PORT_CALC); export ETHERCALC_PORT_CALC

# ensure that directories exist
bash -c "if [ ! -d ${EXPORT_PARENT_DIR}/export         ]; then mkdir ${EXPORT_PARENT_DIR}/export;         fi"
bash -c "if [ ! -d ${EXPORT_PARENT_DIR}/log            ]; then mkdir ${EXPORT_PARENT_DIR}/log;            fi"
bash -c "if [ ! -d ${EXPORT_PARENT_DIR}/log/supervisor ]; then mkdir ${EXPORT_PARENT_DIR}/log/supervisor; fi"

# DOCKER_USER=$USER ; export DOCKER_USER
# DOCKER_GROUP=$(grep "^$USER:" /etc/passwd | cut -f 4 -d ':') ; export DOCKER_GROUP
DOCKER_USER=galaxy
# extract and export UID for docker user
DOCKER_UID=$(grep "^$DOCKER_USER:" /etc/passwd | cut -f 3 -d ':'); export DOCKER_UID

echo MY_DIR                    = $MY_DIR
echo DOCKER_UID                = $DOCKER_UID
echo GALAXY_IDENTITY           = $GALAXY_IDENTITY
echo GALAXY_CONFIG_ADMIN_USERS = $GALAXY_CONFIG_ADMIN_USERS
echo EXPORT_PARENT_DIR         = $EXPORT_PARENT_DIR
echo GALAXY_PORT_FTP           = $GALAXY_PORT_FTP
echo GALAXY_PORT_HTTP          = $GALAXY_PORT_HTTP
echo ETHERCALC_PORT_CALC       = $ETHERCALC_PORT_CALC

set +e

###############################

# start the suite of docker containers for the Galaxy instance 
echo running docker-compose up for UID=$DOCKER_USER
(
  docker-compose -p ${GALAXY_IDENTITY} -f ${MY_DIR}/galaxy-compose.yml up -d
) && (
  echo docker-compose up succeeded
)

#!/bin/bash

# find the directory containing this script
MY_SOURCE="${BASH_MY_SOURCE[0]}"
while [ -h "$MY_SOURCE" ]; do # resolve $MY_SOURCE until the file is no longer a symlink
  MY_DIR="$( cd -P "$( dirname "$MY_SOURCE" )" && pwd )"
  MY_SOURCE="$(readlink "$MY_SOURCE")"
  [[ $MY_SOURCE != /* ]] && MY_SOURCE="$MY_DIR/$MY_SOURCE" # if $MY_SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
MY_DIR="$( cd -P "$( dirname "$MY_SOURCE" )" && pwd )"
MY_DIR_NAME=$(echo $MY_DIR | sed -e 's?.*/??')

# abort if any command fails or enviroment variable is not set properly
set -eu

# set up GALAXY_IDENTITY for this script and galaxy-compose.xml
GALAXY_IDENTITY=$(cat ${MY_DIR}/GALAXY_IDENTITY); export GALAXY_IDENTITY

# set up GALAXY_CONFIG_MASTER_API_KEY for this script and galaxy-compose.xml
GALAXY_CONFIG_MASTER_API_KEY=not_used_to_stop_galaxy; export GALAXY_CONFIG_MASTER_API_KEY

# set up GALAXY_CONFIG_ADMIN_USERS for galaxy-compose.xml
GALAXY_CONFIG_ADMIN_USERS=$(cat ${MY_DIR}/GALAXY_CONFIG_ADMIN_USERS); export GALAXY_CONFIG_ADMIN_USERS

# set up EXPORT_PARENT_DIR for galaxy-compose.xml
EXPORT_PARENT_DIR=$(cat ${MY_DIR}/EXPORT_PARENT_DIR); export EXPORT_PARENT_DIR

# DOCKER_USER=$USER ; export DOCKER_USER
# DOCKER_GROUP=$(grep "^$USER:" /etc/passwd | cut -f 4 -d ':') ; export DOCKER_GROUP
DOCKER_USER=galaxy
# extract and export UID for docker user
DOCKER_UID=$(grep "^$DOCKER_USER:" /etc/passwd | cut -f 3 -d ':'); export DOCKER_UID

set +e
echo stop Galaxy processes gracefully - notably, postgresql
sudo -E docker exec -ti ${GALAXY_IDENTITY}_galaxy_1 bash -c "supervisorctl stop all"

###############################

# stop the suite of docker containers for the Galaxy instance 
echo running docker-compose down for UID=$DOCKER_USER
(
  sudo -E docker-compose -p ${GALAXY_IDENTITY} -f ${MY_DIR}/galaxy-compose.yml down
) && (
  echo docker-compose down succeeded
)

echo cleaning up volumes that will never be used again
# docker volume rm `docker volume ls  -f 'dangling=true' | grep -v DRIVER | sed -e "s/local[ ]*//"`
sudo -E docker volume rm $( sudo docker volume ls -q -f 'dangling=true' )
echo clean-up completed

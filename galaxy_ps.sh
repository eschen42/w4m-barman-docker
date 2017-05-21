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

sudo -E docker exec -ti ${GALAXY_IDENTITY}_galaxy_1 bash -c "ps ajxf | cat"


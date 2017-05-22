# w4m-barman-docker
W4M barman integration

## Required files

Set up files in this directory with the needed parameters before running ./start.sh or ./stop.sh; tune the contents as needed or desired

```bash
more API_KEY ETHERCALC_PORT_CALC EXPORT_PARENT_DIR GALAXY_CONFIG_ADMIN_USERS GALAXY_IDENTITY GALAXY_PORT_FTP GALAXY_PORT_HTTP | cat
::::::::::::::
API_KEY
::::::::::::::
barman
::::::::::::::
ETHERCALC_PORT_CALC
::::::::::::::
9000
::::::::::::::
EXPORT_PARENT_DIR
::::::::::::::
/path/to/store/exported/barman/data
::::::::::::::
GALAXY_CONFIG_ADMIN_USERS
::::::::::::::
pinacolada@example.net
::::::::::::::
GALAXY_IDENTITY
::::::::::::::
barman
::::::::::::::
GALAXY_PORT_FTP
::::::::::::::
9021
::::::::::::::
GALAXY_PORT_HTTP
::::::::::::::
9080
```
## Starting and stopping Galaxy

If you are not running as root, you will want to use `sudo` to start or stop Galaxy, e.g.:

```bash
# Start Galaxy
sudo ./start.sh

# Stop Galaxy
sudo ./stop.sh

```

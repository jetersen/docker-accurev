#!/bin/bash

if [ ! -f "${ACCUREV_HOME}/license/aclicense.txt" ]; then
    >&2 echo "You need to mount an aclicense.txt under ${ACCUREV_HOME}/license/"
    exit 1
fi

# Overwrite cnf files, setting hostName to containers ID
sed -i "2s/.*/MASTER_SERVER = ${HOSTNAME}/" ./bin/acserver.cnf
# Set client.cnf to just target localhost defaultport 5050
sed -i "1s/.*/SERVERS = localhost:5050/" ./bin/acclient.cnf

# Start the database, we need to update its content, because we have a new hostName
acserverctl dbstart
# Update accurev information, login as default user postgres with password
printf "${POSTGRES_PASSWORD}\ny\n" | maintain server_properties update postgres

# Start the remaining Accurev services, Accurev included
acserverctl start

echo "Accurev server is now ready. Enjoy!"
# Keep the container running after setup
sleep infinity

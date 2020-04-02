#!/bin/bash

# This script should be placed in the /etc/init.d directory in order to work
# It will check for containers that should be started on boot and gns-start them


# [Init variables]
# The path of the gnomon-server directory
ROOT_PATH=$(dirname "$0")       # This dev value will be replaced during install

# [Enable Logs]
exec 3>&1 4>&2
trap 'exec 2>&4 1>&3' 0 1 2 3
exec 1>$ROOT_PATH/logs/logs.out 2>&1

# [Append sources]
. $ROOT_PATH/.gns-config
. $ROOT_PATH/utilities/messages.sh
. $ROOT_PATH/utilities/containers.sh


# [Check if enabled in gns-config]
(( $START_ON_BOOT_ENABLED )) || exit 0
 

# [Get containers datas]
containers_data=$ROOT_PATH/data/containers.json
containers_pathes=$(jq '.containers[].path' $containers_data) 


# [Iterate on containers]
for container_path in $containers_pathes
do
    # Remove " from data
    container_path=${container_path//[\"]/}

    # Get gnomonfile
    getGnomonfile $container_path || continue

    # Check if start on boot is enabled for container
    [[ $(jq '.startOnBoot' $gnomonfile) == true ]] || continue

    # Check if container should be updated on start (TODO: put it in gns start)
    [[ $(jq '.updateOnStart' $gnomonfile) == true ]] && gns update $container_path || continue

    # Starts the container
    gns start $container_path
done
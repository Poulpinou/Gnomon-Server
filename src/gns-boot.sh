#!/bin/sh

# This script should be placed in the /etc/init.d directory in order to work
# It will check for containers that should be started on boot and gns-start them


# [Init variables]
# The path of the gnomon-server directory
ROOT_PATH=$(dirname "$0")       # This dev value will be replaced during install


# [Append sources]
. $ROOT_PATH/.gns-config
. $ROOT_PATH/utilities/messages.sh
. $ROOT_PATH/utilities/containers.sh


# [Enable Logs]
exec 3>&1 4>&2
trap 'exec 2>&4 1>&3' 0 1 2 3
exec 1>>$LOG_FILE.boot 2>&1


# [Check if enabled in gns-config]
(( $START_ON_BOOT_ENABLED )) || (echo "Start on boot disabled in $ROOT_PATH/.gns-config" &&  exit 0)
 echo "${s_title}=> Gnomon auto boot starting on $(date) <=${s_normal}"


# [Get containers datas]
containers_data=$ROOT_PATH/data/containers.json
containers_pathes=$(jq -r '.containers[].path' $containers_data) 


# [Iterate on containers]
for container_path in $containers_pathes
do
    # Get gnomonfile
    getGnomonfile $container_path 2 || continue
    
    # Check if start on boot is enabled for container
    [[ $(jq '.startOnBoot' $gnomonfile) == true ]] || continue

    # Starts the container
    gns start $container_path
done
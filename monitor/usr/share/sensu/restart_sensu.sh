#!/bin/bash

#
# Convenience script to restart all of the sensu components on a server
#

if [ "`whoami`" != "root" ]; then
    echo "Must be run as root"
    exit 1
fi

echo "## Restart server"
service sensu-server restart

echo "## Restart api"
service sensu-api restart

echo "## Restart client"
service sensu-client restart

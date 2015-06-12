#!/bin/bash

# 6/11/15 JDS 
#send_to_graphite.sh
#take an exisiting log, change the date field to seconds, 
#    get a value and stuff it into grpahite
# Requires a log tail util. Easy and portable option:
#  pip install pygtail 


#gdate used on OS X 
#date=/opt/local/bin/gdate
date=/bin/date

nc=/usr/bin/nc


#LOG=/Users/jschuster/peanut_wrk/logs/wrk
LOG=/mnt/data/catalog_wrapper.log
#LOG_TAIL=/Users/jschuster/.virtualenvs/peanut_wrk/bin/pygtail
LOG_TAIL=/bin/pygtail
METRIC_PATH=sensu.peanut_cloud_htspotlight_com.catalog
GRAPH_HOST=aztec.cloud.htspotlight.com


grep Total $LOG |while read LINE
do 
# -0000 = UTC adjust to host TZ as needed
DATE=`echo $LINE |awk '{print $1, $2 "-0000"}'|tr -d \[` 
SDATE=`$date +%s -d "$DATE"`
TYPE=`echo $LINE |awk '{print $4}'`
VALUE=`echo $LINE |awk '{print $6}'`
PAYLOAD="$METRIC_PATH.$TYPE $VALUE $SDATE"
echo $PAYLOAD
echo "$PAYLOAD" |$nc $GRAPH_HOST 2003
done

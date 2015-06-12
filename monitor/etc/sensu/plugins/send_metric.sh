#!/bin/bash

# 6/12/15 JDS 
#send_metrics.sh
#take an exisiting log, change the date field to seconds, 
#    get a value and stuff it into grpahite
# Requires a log tail util. Easy and portable option:
#  pip install pygtail 


date=/bin/date
nc=/usr/bin/nc
LOG_TAIL=/usr/local/bin/pygtail


HELP () {
	echo ""
    echo "send_metrics.sh -g value -m value -l value "
	echo "-g | --GRAPH_HOST --> Host name of Graphite server "
    echo "-m | --METRIC_PATH --> Metric path in graphite "
    echo "-l | --LOG_FILE -->  Log file to check"
    echo "-s | --STRING --> String to search for in the log file"
    echo "-h | --help --> This message"
 	echo ""
}


while [ "$1" != "" ]; do
    case $1 in
        -m | --METRIC_PATH )   shift
                                METRIC_PATH=$1
                                ;;
        -g | --GRAPH_HOST )    shift
								GRAPH_HOST=$1
                                ;;
        -l | --LOG_FILE )	   shift
        						LOG_FILE=$1
        						;; 
        -s | --STRING )        shift
                                STRING=$1
                                ;;						
        -h | --help )          HELP
                                exit
                                ;;
        * )                    HELP
                                exit 1
    esac
    shift
done


if [[ -z $METRIC_PATH ]]; then
	echo ""
	echo "Metric path not set"
	HELP
	exit 1
fi

if [[ -z $GRAPH_HOST ]]; then
	echo ""
	echo "Graphite host not set"
	HELP
	exit 1
fi

if [[ -z $LOG_FILE  ]]; then
	echo ""
	echo "Log file not set"
	HELP
	exit 1
fi

if [[ -f "LOG_FILE" ]]; then
	echo ""
	echo "Log file not a regular file"
	HELP
	exit 1
fi

if [[ -z $STRING ]]; then
	echo ""
	echo "Search string not set"
	HELP
	exit 1
fi


$LOG_TAIL $LOG_FILE | grep $STRING |while read LINE
do 
# -0000 = UTC adjust to host TZ as needed
DATE=`echo $LINE |awk '{print $1, $2 "-0000"}'|tr -d \[` 
SDATE=`$date +%s -d "$DATE"`
TYPE=`echo $LINE |awk '{print $4}'`
VALUE=`echo $LINE |awk '{print $6}'`
PAYLOAD="$METRIC_PATH.$TYPE $VALUE $SDATE"
echo $PAYLOAD
#echo "$PAYLOAD" |$nc $GRAPH_HOST 2003
done

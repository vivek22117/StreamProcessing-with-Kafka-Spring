#!/usr/bin/env bash

source /etc/environment

DAEMON="java"
NAME="rsvp"
RSVP_LOCATION=/home/ec2-user/${NAME}
MAIN_CLASS=com.ddsolutions.kafka.RSVPCollectionApplication
LOG_FOLDER=${RSVP_LOCATION}/logs
PID_FILE=${LOG_FOLDER}/${NAME}.pid
DAEMONOPTS="-jar --spring.profiles.active=${Environment} /home/ec2-user/${NAME}/rsvp-collection-tier-kafka-kinesis-0.0.1-webapp.jar"


JAVAOPTS=""
if [[ "${Environment}" == "devl" ]]; then
  JAVAOPTS="-Xms512m -Xmx1024m"
elif [[ "${Environment}" == "prod" ]]; then
  JAVAOPTS="-Xms1024m -Xmx2048m"
fi



case "$1" in
start)
        rm -f ${LOG_FOLDER}/sysout.log
        printf "%-50s" "Starting $NAME..." >> ${LOG_FOLDER}/start.log
        PID=`${DAEMON} ${JAVAOPTS} ${DAEMONOPTS} > ${LOG_FOLDER}/sysout.log 2>&1 & echo $!`
        if [[ -z ${PID} ]]; then
            printf "%s\n" "Fail" >> ${LOG_FOLDER}/start.log
            exit 1
        else
            echo ${PID} >> ${LOG_FOLDER}/start.log
            echo ${PID} > ${PID_FILE}
            printf "%s\n" "Ok" >> ${LOG_FOLDER}/start.log
            exit 0
        fi
;;
status)
        printf "%-50s" "Checking $NAME..." ${LOG_FOLDER}/status.log
        if ! /usr/sbin/lsof -i:5000
        then
            echo "`date` - 5000 is free" >> ${LOG_FOLDER}status.log
        else
            echo "`date` - 5000 is occupied" >> ${LOG_FOLDER}status.log
        fi
;;
stop)
        printf "%-50s" "Stopping $NAME..." >> ${LOG_FOLDER}/status.log
            PID=`cat ${PID_FILE}`
        if [ -f ${PID_FILE} ]; then
            kill ${PID}
            printf "%s\n" "Ok"
            rm -f ${PID_FILE}
        else
            printf "%s\n" "pidfile not found"
        fi
;;
restart)
        $0 stop
        $0 start
;;

*)
        echo "Usage: $0 {status|start|stop|restart}"
        exit 1
esac
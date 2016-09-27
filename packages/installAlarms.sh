#!/bin/bash
#
# use the command line interface to install Git package.
#
: ${WHISK_SYSTEM_AUTH:?"WHISK_SYSTEM_AUTH must be set and non-empty"}
AUTH_KEY=$WHISK_SYSTEM_AUTH

: ${OPENWHISK_HOME:?"OPENWHISK_HOME must be set and non-empty"}
SCRIPTDIR="$(cd $(dirname "$0")/ && pwd)"
PACKAGE_HOME=$SCRIPTDIR
source "$PACKAGE_HOME/util.sh"

ALARM_HOST=`fgrep alarmstrigger.host= "$OPENWHISK_HOME/whisk.properties" | cut -d'=' -f2`
ALARM_PORT=`fgrep alarmstrigger.host.port= "$OPENWHISK_HOME/whisk.properties" | cut -d'=' -f2`
ALARM_PACKAGE_ENDPOINT=$ALARM_HOST':'$ALARM_PORT
echo '  alarms trigger package endpoint:' $ALARM_PACKAGE_ENDPOINT

echo Installing Alarms package.

createPackage alarms \
     -a description 'Alarms and periodic utility' \
     -a parameters '[ {"name":"cron", "required":true}, {"name":"trigger_payload", "required":false} ]' \
     -p package_endpoint "$ALARM_PACKAGE_ENDPOINT" \
     -p cron '' \
     -p trigger_payload ''

waitForAll

install "$PACKAGE_HOME/alarms/alarm.js"      alarms/alarm \
     -a description 'Fire trigger when alarm occurs' \
     -a feed true

waitForAll

echo Alarms package ERRORS = $ERRORS
exit $ERRORS

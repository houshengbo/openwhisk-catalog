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

CLOUDANT_TRIGGER_HOST=`fgrep cloudanttrigger.host= "$OPENWHISK_HOME/whisk.properties" | cut -d'=' -f2`
CLOUDANT_TRIGGER_PORT=`fgrep cloudanttrigger.host.port= "$OPENWHISK_HOME/whisk.properties" | cut -d'=' -f2`
CLOUDANT_PROVIDER_ENDPOINT=$CLOUDANT_TRIGGER_HOST':'$CLOUDANT_TRIGGER_PORT
echo '  cloudant trigger package endpoint:' $CLOUDANT_PROVIDER_ENDPOINT

echo Installing Cloudant package.

createPackage cloudant \
    -a description "Cloudant database service" \
    -a parameters '[ {"name":"bluemixServiceName", "required":false, "bindTime":true}, {"name":"username", "required":true, "bindTime":true, "description": "Your Cloudant username"}, {"name":"password", "required":true, "type":"password", "bindTime":true, "description": "Your Cloudant password"}, {"name":"host", "required":true, "bindTime":true, "description": "This is usually your username.cloudant.com"}, {"name":"dbname", "required":false, "description": "The name of your Cloudant database"}, {"name":"includeDoc", "required":false, "type": "boolean", "description": "Should the return value include the full documents, or only the document ID?"}, {"name":"overwrite", "required":false, "type": "boolean"} ]' \
    -p package_endpoint "$CLOUDANT_PROVIDER_ENDPOINT"
# \
#    -p bluemixServiceName 'cloudantNoSQLDB' \
#    -p host '' \
#    -p username '' \
#    -p password '' \
#    -p dbname ''

waitForAll

install "$PACKAGE_HOME/cloudant/changes.js" \
    cloudant/changes \
    -t 90000 \
    -a feed true \
    -a description 'Database change feed' \
    -a parameters '[ {"name":"dbname", "required":true}, {"name":"includeDoc", "required":false} ]'

waitForAll

echo Cloudant package ERRORS = $ERRORS
exit $ERRORS

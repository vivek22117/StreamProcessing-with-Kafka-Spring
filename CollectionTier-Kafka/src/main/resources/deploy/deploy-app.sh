#!/usr/bin/env bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

REVISION=$1

if [[ -z "$REVISION" ]]; then
	echo "No revision specified!"
	exit 1
fi

DEPLOYMENT_BUCKET =`echo "$STACK_OUTPUTS" | grep webappdeploymentbucket`
DEPLOYMENT_GROUP=`echo "$STACK_OUTPUTS" | grep WebappDeploymentGroup`
APPLICATION_NAME=`echo "$STACK_OUTPUTS" | grep WebappApplication`

aws deploy create-deployment --application-name $APPLICATION_NAME \
	--s3-location bucket="$DEPLOYMENT_BUCKET",key="$REVISION",bundleType=zip \
	--deployment-group-name $DEPLOYMENT_GROUP
#!/bin/bash

# Store the arguments passed
arguments=${1}
# Seperate the call name that should match our curls.json file
callName=$(echo ${arguments} | cut -d " " -f 1)
# Seperate the call method that should match our curls.json file
callMethod=$(echo ${arguments} | cut -d " " -f 2)
# Deployment version ID stored as env
deploymentVersionId=${BAMBOO_DEP_VERSION_ID}
# Get the API URL to call which is stored in curs.json
getApiUrl=$(cat $(pwd)/config/curlsh.json | jq -r .${callName}.${callMethod} )
apiUrl=$(echo "${getApiUrl}" | sed "s|{deploymentVersionId}|${deploymentVersionId}|g")

. $(pwd)/src/curlsh.sh "${apiUrl}"
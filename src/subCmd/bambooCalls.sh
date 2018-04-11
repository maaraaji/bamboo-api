#!/bin/bash

# Variables
# If any search Terms
searchTerm=""
# In depth search Keys
callInMethodKey=""
callInNameKey=""
callInNameParent=""

# Seperate the call method that should match our curls.json file
# callMethod=$(echo ${arguments} | cut -d " " -f 1)
callMethod=${1}

# Seperate the call name that should match our curls.json file
# callName=$(echo ${arguments} | cut -d " " -f 2)
callName=${2}

# If call method have any search terms, then append it to the URL
if [[ ${callName} =~ "=" ]]; then
    searchTerm=$(echo ${callName} | cut -d "=" -f 2)
    callName=$(echo ${callName} | cut -d "=" -f 1)
fi

# Store the arguments passed
if [[ $# -gt 2 ]]; then
    callInMethodKey=${3}
    callInNameKey=${4}
    if [[ ${callInNameKey} = "" ]]; then
        # Get the API Parent of CallInMethod
        callInNameParent=$(cat $(pwd)/config/curlsh.json | jq -r .${callMethod}.${callName}.${callInMethod}.parent) || usage;
    else
        # Get the value of the CallInMethodValue
        callInNameParent=$(cat $(pwd)/config/curlsh.json | jq -r .${callMethod}.${callName}.${callInMethod}.parent)
        callInName=$(cat $(pwd)/config/curlsh.json | jq -r .${callMethod}.${callName}.${callInMethodKey}.${callInNameKey})
    fi

fi

# Deployment version ID stored as env
deploymentVersionId=${BAMBOO_DEP_VERSION_ID}

# Get the API URL to call which is stored in curs.json
getApiUrl=$(cat $(pwd)/config/curlsh.json | jq -r .${callMethod}.${callName}.uri)
apiUrl=$(echo "${getApiUrl}" | sed "s|{deploymentVersionId}|${deploymentVersionId}|g")

# Call the curl URL to fetch the results
. $(dirname ${0})/curlsh.sh "${apiUrl}?searchTerm=${searchTerm}" "${callInNameParent}" "${callInName}"
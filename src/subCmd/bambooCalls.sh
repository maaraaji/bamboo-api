#!/bin/bash

# Variables
# If any search Terms
searchTerm=""
# In depth search Keys
callInMethodKey=""
callInNameKey=""
callInNameParent=""

# Get the URI from the curlsh.json within whichever object (dict or hash) you configured
function getUri() {
    arguments=""
    success=0
    for X in ${@}; do
        arguments="${arguments}.${X}"
        case ${success} in
            0)
                if [[ $(cat /Users/gk/GK/GURU/Open_Source/bamboo-api/src/config/curlsh.json | jq ${arguments} | jq 'has("uri")') = "true" ]]; then
                    getApiUrl=$(cat $(pwd)/config/curlsh.json | jq -r ${arguments}.uri)
                    echo ${getApiUrl}; success=1
                fi
            ;;
        esac
    done
}
getUri ${@}

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
        callInNameParent=$(cat $(pwd)/config/curlsh.json | jq -r .${callMethod}.${callName}.${callInMethod}.parent 2>/dev/null) || 
        callInNameParent=$(cat $(pwd)/config/curlsh.json | jq -r .${callMethod}.${callName}.${callInMethod});
        # echo ${callInNameParent}
    else
        # Get the value of the CallInMethodValue
        callInNameParent=$(cat $(pwd)/config/curlsh.json | jq -r .${callMethod}.${callName}.${callInMethod}.parent)
        callInName=$(cat $(pwd)/config/curlsh.json | jq -r .${callMethod}.${callName}.${callInMethodKey}.${callInNameKey})
        # echo ${callInNameParent}
    fi
fi

# Deployment version ID stored as env
deploymentVersionId=${BAMBOO_DEP_VERSION_ID}

# Get the API URL to call which is stored in curs.json
# getApiUrl=$(cat $(pwd)/config/curlsh.json | jq -r .${callMethod}.${callName}.uri)
apiUrl=$(echo "${getApiUrl}" | sed "s|{deploymentVersionId}|${deploymentVersionId}|g")



# Call the curl URL to fetch the results
. $(dirname ${0})/curlsh.sh "${apiUrl}?searchTerm=${searchTerm}" "${callInNameParent}" "${callInName}"
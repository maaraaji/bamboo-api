#!/bin/bash

# Variables
# If any search Terms
searchTerm=""
# In depth search Keys
callInMethodKey=""
callInNameKey=""
callInNameParent=""
argumentValues=""
# Get the URI from the curlsh.json within whichever object (dict or hash) you configured
function getUri() {
    arguments=""
    success=0
    for X in ${@}; do
        arguments="${arguments}.${X}"
        echo ${arguments}
        case ${success} in
            0)  if [[ $(cat /Users/gk/GK/GURU/Open_Source/bamboo-api/src/config/curlsh.json | jq ${arguments} | jq 'has("uri")') = "true" ]]; then
                    getApiUrl=$(cat $(pwd)/config/curlsh.json | jq -r ${arguments}.uri); success=1;
                fi  ;;
            1)
                argumentValues="$(cat /Users/gk/GK/GURU/Open_Source/bamboo-api/src/config/curlsh.json | jq -r ${arguments})"
        esac
    done
    echo ${argumentValues}
    if [[ ${success} -eq 0 ]]; then echo "Update the API URI for ${arguments} in curls.json for your argument manupulation buddy!"; exit 1; fi
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
# . $(dirname ${0})/curlsh.sh "${getApiUrl}?searchTerm=${searchTerm}" "${argumentValues}"
. $(dirname ${0})/curlsh.sh "${getApiUrl}" "${argumentValues}"
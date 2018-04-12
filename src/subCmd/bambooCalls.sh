#!/bin/bash

# Variables
argumentValues=""

# Get the URI from the curlsh.json within whichever object (dict or hash) you configured
function getUriAndArgumentValues() {
    arguments=""
    success=0
    for X in ${@}; do
        arguments="${arguments}.${X}"
        case ${success} in
            0)  if [[ $(cat /Users/gk/GK/GURU/Open_Source/bamboo-api/src/config/curlsh.json | jq ${arguments} | jq 'has("uri")') = "true" ]]; then
                    getApiUrl=$(cat $(pwd)/config/curlsh.json | jq -r ${arguments}.uri); success=1;
                fi  ;;
            1)
                argumentValues="$(cat /Users/gk/GK/GURU/Open_Source/bamboo-api/src/config/curlsh.json | jq -r ${arguments})"
        esac
    done
    if [[ "${argumentValues}" =~ "{" ]]; then echo "Buddy! What do you want ${X}?"; exit 1; fi
    if [[ ${success} -eq 0 ]]; then echo "Buddy! If the child dicts don't have API URI, then update the API URI for ${arguments} in curls.json or try indepth."; exit 1; fi
}
getUriAndArgumentValues ${@}

# Deployment version ID stored as env
deploymentVersionId=${BAMBOO_DEP_VERSION_ID}

# Sourcing the curlsh.sh to fetch the results
# . $(dirname ${0})/curlsh.sh "${getApiUrl}?searchTerm=${searchTerm}" "${argumentValues}"
. $(dirname ${0})/curlsh.sh "${getApiUrl}" "${argumentValues}"
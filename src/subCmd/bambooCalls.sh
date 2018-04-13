#!/bin/bash

# Variables
argumentValues=""
# echo $@

function customPrint() {
    # echo "${1}"
    echo "${1}"
}

# Function to get the Value from the string with format key=value
function getValue() {
    echo ${1} | cut -d "=" -f 2
}

# Function to get the key from the string with format key=value
function getKey() {
    echo ${1} | cut -d "=" -f 1
}

function checkForQuery() {
    echo $(getKey ${1})
}

# Get the URI from the curlsh.json within whichever object (dict or hash) you configured
function getUriAndArgumentValues() {
    arguments=""
    success=0
    for X in ${@}; do
        arguments="${arguments}.${X}"
        if [[ ${arguments} =~ "=" ]]; then arguments=$(checkForQuery "${arguments}"); fi
        case ${success} in
            0)  if [[ $(cat $(pwd)/config/curlsh.json | jq ${arguments} | jq 'has("uri")') = "true" ]]; then
                    getApiUrl=$(cat $(pwd)/config/curlsh.json | jq -r ${arguments}.uri); success=1;
                fi  ;;
        esac
    done
    argumentValues="$(cat $(pwd)/config/curlsh.json | jq -r ${arguments})"
    # echo ${arguments}
    # echo ${argumentValues}
    if [[ "${argumentValues}" =~ "{" ]]; then echo "Buddy! What do you want in ${X}?"; exit 1; fi
    if [[ ${success} -eq 0 ]]; then echo "Buddy! If the child dicts don't have API URI, then update the API URI for ${arguments} in curls.json or try indepth."; exit 1; fi
}
getUriAndArgumentValues ${@}

# Deployment version ID stored as env
deploymentVersionId=${BAMBOO_DEP_VERSION_ID}

# Sourcing the curlsh.sh to fetch the results
# . $(dirname ${0})/curlsh.sh "${getApiUrl}?searchTerm=${searchTerm}" "${argumentValues}"
. $(dirname ${0})/curlsh.sh "${getApiUrl}" "${argumentValues}"
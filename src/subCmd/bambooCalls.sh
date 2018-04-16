#!/bin/bash

# Variables
argumentValues="${1}"
function customPrint() {
    echo "${1}"
}

# Function to get the Value from the string with format key=value
function getValue() {
    echo ${1} | cut -d ":" -f 2
}

# Function to get the key from the string with format key=value
function getKey() {
    echo ${1} | cut -d ":" -f 1
}

# function haveQuery() {
#     queryTerm=$(getKey ${1})
#     echo ${queryTerm}
#     result=$(cat $(pwd)/config/curlsh.json | jq ${queryTerm} | jq 'has("query")') 2>/dev/null
#     if [[ "${result}"  = "true" ]]; then
#         return 0
#     else
#         return 1
#     fi
# }


function runThroughAndCheckIfItHas() {
    # echo ${@}
    arguments=""
    whereToCheck=${1}
    inWhat=${2}
    whatToCheck=${3}
    # echo Yummy${whereToCheck} ${inWhat} ${whatToCheck}
    success=0
    for X in ${inWhat[@]}; do
        arguments="${arguments}.${X}"
        # echo "cat ${whereToCheck} | jq ${arguments} | jq 'has(\"${whatToCheck}\")'"
        case ${success} in
            0)  if [[ $(cat ${whereToCheck} | jq ${arguments} | jq "has(\"${whatToCheck}\")") = "true" ]]; then
                    echo $(cat ${whereToCheck} | jq -r ${arguments}.${whatToCheck}); success=1
                fi
            ;;
        esac
    done
}

if [[ ${argumentValues} =~ ":" ]]; then
    queryParams=$(echo ${@} | cut -d ":" -f 2)
    whatNeedsQuery=$(echo ${argumentValues} | cut -d ":" -f 1 )
    # echo ${whatNeedsQuery}
    # queryJson=$(runThroughAndCheckIfItHas "$(pwd)/config/curlsh.json" "${whatNeedsQuery}" "query")
    # echo ${queryJson}
    # getQueryParamValue=$(runThroughAndCheckIfItHas "$(pwd)/config/curlsh.json" "${whatNeedsQuery}" "query")
    # echo ${getQueryParamValue}
    # if [[ ${?} -eq 0 ]]; then
    #     echo "Yahoo! Trying the query params"
    # else
    #     echo "No query configured buddy! Configure it and try using :"
    # fi
    argumentValues="$(echo ${argumentValues} | sed "s|:${queryParams}:||g" )"
    # echo "${whatNeedsQuery} needs ${queryParams}"
fi

# Get the URI from the curlsh.json within whichever object (dict or hash) you configured
function getUriAndArgumentValues() {
    arguments=""
    # success=0
    # for X in ${argumentValues}; do
    #     arguments="${arguments}.${X}"
    #     case ${success} in
    #         0)  if [[ $(cat $(pwd)/config/curlsh.json | jq ${arguments} | jq 'has("uri")') = "true" ]]; then
    #                 getApiUrl=$(cat $(pwd)/config/curlsh.json | jq -r ${arguments}.uri); success=1;
    #             fi  ;;
    #     esac
    # done
    runThroughAndCheckIfItHas "$(pwd)/config/curlsh.json" "${argumentValues}" "uri"
    # echo "runThroughAndCheckIfItHas \"$(pwd)/config/curlsh.json\" \"${argumentValues}\" \"uri\""
    # getApiUrl=$(runThroughAndCheckIfItHas "$(pwd)/config/curlsh.json" "${argumentValues}" "uri")
    # argumentValues="$(cat $(pwd)/config/curlsh.json | jq -r ${arguments})"
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
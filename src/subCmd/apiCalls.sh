#!/bin/bash

passedArguments="${1}"
queryParams=""
uriEnd=""

function init() {
    dictValue=""
    fullPath=""
}   

function getDictValueAndFullPath() {
    fullPath=""
    whereToCheck=${1}
    inWhat=${2}
    whatToCheck=${3}
    success=0
    for x in ${inWhat[@]}; do
        fullPath=${fullPath}.${x}
        case ${success} in
            0)  
                # echo "cat ${whereToCheck} | jq ${fullPath} | jq has(\"${whatToCheck}\")"
                if [[ $(cat ${whereToCheck} | jq ${fullPath} | jq "has(\"${whatToCheck}\")") = "true" ]]; then
                    dictValue=$(cat ${whereToCheck} | jq -r ${fullPath}.${whatToCheck}); success=1
                fi
            ;;
        esac
    done
}

function getUrlPathAndJqValues() {
    getDictValueAndFullPath "$(pwd)/config/curlsh.json" "${passedArguments}" "uri"
    apiUrl=${dictValue}
    argumentValues="$(cat $(pwd)/config/curlsh.json | jq -r ${fullPath})"
    init
}

if [[ ${passedArguments} =~ ":" ]]; then
    query=$(echo ${passedArguments} | cut -d ":" -f 2 )
    whatNeedsQuery=$(echo ${passedArguments} | cut -d ":" -f 1 )
    getDictValueAndFullPath "$(pwd)/config/curlsh.json" "${whatNeedsQuery}" "query"
    isQuery=0
    if [[ ! ${dictValue} = "" ]]; then
        for y in ${query}; do
            field="$(echo ${y} | cut -d "=" -f 1)"
            fieldValue=$(echo ${y} | cut -d "=" -f 2)
            if [[ ${field} = "end" ]]; then
                getDictValueAndFullPath "$(pwd)/config/curlsh.json" "${whatNeedsQuery}.query" "${field}"
                if [[ "${dictValue}" = "true" ]]; then
                    uriEnd=/${fieldValue}.json
                fi
                init
            else 
                getDictValueAndFullPath "$(pwd)/config/curlsh.json" "${whatNeedsQuery}.query.after" "${field}"
                if [[ ! "${dictValue}" = "" ]]; then
                    if [[ ${isQuery} = 0 ]]; then
                        queryParams="?${dictValue}=${fieldValue}"
                        isQuery=isQuery+1
                    else
                        queryParams="${queryParams}&${dictValue}=${fieldValue}"
                    fi
                fi
                init
            fi
        done
    else echo "No queries configured Buddy!"
    fi
    passedArguments="$(echo ${passedArguments} | sed "s|:${query}:||g" )"
fi

getUrlPathAndJqValues
# echo "$(dirname ${0})/curlsh.sh "${apiUrl}${uriEnd}${queryParams}" "${argumentValues}""
if [[ ${uriEnd} =~ "{" || ${queryParams} =~ "{" || ${argumentValues} =~ "{" ]]; then
    . $(dirname ${0})/curlsh.sh "${apiUrl}${uriEnd}${queryParams}" ""
    exit 1
fi
. $(dirname ${0})/curlsh.sh "${apiUrl}${uriEnd}${queryParams}" "${argumentValues}"
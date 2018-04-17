#!/bin/bash

passedArguments="${1}"
whenArguments=$(echo "${2}" | sed 's|\"||g')
# echo ${passedArguments}
# echo ${whenArguments}
queryParams=""
uriEnd=""
dir="$(dirname ${0})"
# echo ${whenArguments}

function initGetDictFullPath() {
    dictValue=""
    fullPath=""
    successPath=""
}

function initFieldValue() {
    field=""
    fieldValue=""
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
                if [[ $(cat ${whereToCheck} | jq ${fullPath} | jq "has(\"${whatToCheck}\")") = "true" ]]; then
                    # echo "cat ${whereToCheck} | jq ${fullPath} | jq 'has(\"${whatToCheck}\")'"
                    # echo "cat ${whereToCheck} | jq -r ${fullPath}.${whatToCheck}"
                    dictValue=$(cat ${whereToCheck} | jq -r ${fullPath}.${whatToCheck})
                    successPath=${fullPath}
                    success=1
                fi
            ;;
        esac
    done
}

function processingQueries() {
    if [[ ${passedArguments} =~ ":" ]]; then
        query=$(echo ${passedArguments} | cut -d ":" -f 2 )
        whatNeedsQuery=$(echo ${passedArguments} | cut -d ":" -f 1 )
        getDictValueAndFullPath "${dir}/config/curlsh.json" "${whatNeedsQuery}" "query"
        isQuery=0
        if [[ ! ${dictValue} = "" ]]; then
            for y in ${query}; do
                field="$(echo ${y} | cut -d "=" -f 1)"
                fieldValue=$(echo ${y} | cut -d "=" -f 2)
                if [[ ${field} = "which" ]]; then
                    getDictValueAndFullPath "${dir}/config/curlsh.json" "${whatNeedsQuery}.query" "${field}"
                    if [[ "${dictValue}" = "true" ]]; then
                        uriEnd=/${fieldValue}.json
                    fi
                    initGetDictFullPath
                else 
                    getDictValueAndFullPath "${dir}/config/curlsh.json" "${whatNeedsQuery}.query.after" "${field}"
                    if [[ ! "${dictValue}" = "" ]]; then
                        if [[ ${isQuery} = 0 ]]; then
                            queryParams="?${dictValue}=${fieldValue}"
                            isQuery=isQuery+1
                        else
                            queryParams="${queryParams}&${dictValue}=${fieldValue}"
                        fi
                    fi
                    initGetDictFullPath
                fi
            done
        else echo "No queries configured Buddy!"
        fi
        passedArguments="$(echo ${passedArguments} | sed "s|:${query}:||g" )"
    fi
}

function getUrlPathAndJqValues() {
    getDictValueAndFullPath "${dir}/config/curlsh.json" "${passedArguments}" "uri"
    apiUrl=${dictValue}
    if [[ ! ${uriEnd} = "" ]]; then
        apiUrl=${apiUrl/.json/}
    fi
    # echo ${fullPath}
    argumentValues=".$(cat ${dir}/config/curlsh.json | jq -r ${fullPath})"
    # echo ${argumentValues}
    initGetDictFullPath
    initFieldValue
}

function processingWhen() {
    field=$(echo ${whenArguments} | cut -d "=" -f 1 )
    value=$(echo ${whenArguments} | cut -d "=" -f 2 )
    whatNeedsQuery=${passedArguments}
    getDictValueAndFullPath "${dir}/config/curlsh.json" "${whatNeedsQuery}" "when"
    whatNeedsQuery=$(echo ${successPath} | sed 's|^\.||g')
    getDictValueAndFullPath "${dir}/config/curlsh.json" "${whatNeedsQuery}.when" "${field}"
    withThis="|select(.${dictValue} == \"${value}\")|"
    initGetDictFullPath
    getDictValueAndFullPath "${dir}/config/curlsh.json" "${whatNeedsQuery}.when" "selectObject"
    replaceWhen=${dictValue}
    argumentValues=$(echo ${argumentValues} | sed "s/\[\]./\[\]${withThis}\.${replaceWhen}/g")
    initGetDictFullPath
    initFieldValue
}

processingQueries
getUrlPathAndJqValues
initGetDictFullPath
if [[ ! ${whenArguments} = "" ]]; then
    processingWhen
fi

# echo "$(dirname ${0})/curlsh.sh "${apiUrl}${uriEnd}${queryParams}" "${argumentValues}""
if [[ ${uriEnd} =~ "{" || ${queryParams} =~ "{" || ${argumentValues} =~ "{" ]]; then
    . $(dirname ${0})/curlsh.sh "${apiUrl}${uriEnd}${queryParams}" ""
    exit 1
fi
. $(dirname ${0})/curlsh.sh "${apiUrl}${uriEnd}${queryParams}" "${argumentValues}"
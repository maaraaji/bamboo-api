#!/bin/bash

passedArguments="${1}"
whenArguments=$(echo "${2}" | sed 's|\"||g')
queryParams=""
uriEnd=""
dir="$(dirname ${0})"
B=$(tput bold)
N=$(tput sgr0)
U=$(tput smul)
# echo ${passedArguments}
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
    initGetDictFullPath
    whereToCheck=${1}
    inWhat=${2}
    whatToCheck=${3}
    success=0
    for x in ${inWhat[@]}; do
        fullPath=${fullPath}.${x}
        case ${success} in
            0)  if [[ $(cat ${whereToCheck} | jq ${fullPath} | jq "has(\"${whatToCheck}\")") = "true" ]]; then
                dictValue=$(cat ${whereToCheck} | jq -r ${fullPath}.${whatToCheck}); successPath=${fullPath}; success=1 ; fi ;;
        esac
    done
}

function processingQueries() {
    if [[ ${passedArguments} =~ ":" ]]; then
        haveSubs=$(echo "${passedArguments}" | tr -cd ":" | wc -c)
        sub=$(echo ${passedArguments} | cut -d ":" -f 3 )
        query=$(echo ${passedArguments} | cut -d ":" -f 2 )
        whatNeedsQuery=$(echo ${passedArguments} | cut -d ":" -f 1 )
        # echo ${sub}
        # echo ${query}
        # echo ${whatNeedsQuery}
        getDictValueAndFullPath "${dir}/config/curlsh.json" "${whatNeedsQuery}" "query"
        isQuery=0
        if [[ ! ${dictValue} = "" ]]; then
            for y in ${query}; do
                field="$(echo ${y} | cut -d "=" -f 1)"
                fieldValue=$(echo ${y} | cut -d "=" -f 2)
                if [[ ${field} = "which" ]]; then
                    getDictValueAndFullPath "${dir}/config/curlsh.json" "${whatNeedsQuery}.query" "${field}"
                    if [[ "${dictValue}" = "true" ]]; then uriEnd=/${fieldValue}.json; uriEnd=${uriEnd//\"/} ; fi
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
                fi
            done
        else echo "No queries configured Buddy!"
        fi
        if [[ ${haveSubs} -eq 3 ]]; then
            passedArguments="$(echo ${passedArguments} | sed "s|:${query}:${sub}:||g" )"
        else
            passedArguments="$(echo ${passedArguments} | sed "s|:${query}:||g" )"
            # echo ${uriEnd}
        fi
    fi
}

function processingSubstitutes() {
    field=$(echo ${sub} | cut -d "=" -f 1)
    fieldValue=$(echo ${sub} | cut -d "=" -f 2)
    if [[ ! "${fieldValue}" = "" ]]; then
        eval "${field}"="${fieldValue}"
        substitutedValue=$(echo ${!field})
        apiUrl=$(echo ${apiUrl} | sed "s|{.*}|${substitutedValue}|g")
    fi
}

function getUrlPathAndJqValues() {
    getDictValueAndFullPath "${dir}/config/curlsh.json" "${passedArguments}" "uri"
    apiUrl=${dictValue}
    if [[ ! ${uriEnd} = "" ]]; then apiUrl=${apiUrl/.json/} ; fi
    argumentValues=".$(cat ${dir}/config/curlsh.json | jq -r ${fullPath})"
    initFieldValue
}

function processingWhen() {
    field=$(echo ${whenArguments} | cut -d "=" -f 1 )
    value=$(echo ${whenArguments} | cut -d "=" -f 2 )
    whatNeedsQuery=${passedArguments}
    getDictValueAndFullPath "${dir}/config/curlsh.json" "${whatNeedsQuery}" "when"
    whatNeedsQuery=$(echo ${successPath} | sed 's|^\.||g')
    getDictValueAndFullPath "${dir}/config/curlsh.json" "${whatNeedsQuery}.when" "${field}"
    if [[ "${dictValue}" =~ "{" ]]; then echo "Condition: ${B}${field} not configured${N} using when buddy"; exit 1
    else withThis="|select(.${dictValue} == \"${value}\")|"; fi
    getDictValueAndFullPath "${dir}/config/curlsh.json" "${whatNeedsQuery}.when" "selectObject"
    replaceWhen=${dictValue}
    argumentValues=$(echo ${argumentValues} | sed "s/\[\]./\[\]${withThis}\.${replaceWhen}/g")
    initFieldValue
}

processingQueries
getUrlPathAndJqValues
if [[ ${haveSubs} -eq 3 && ! "${sub}" = "" ]]; then
    processingSubstitutes
fi
if [[ ! ${whenArguments} = "" ]]; then
    processingWhen
fi

# echo "$(dirname ${0})/curlsh.sh "${apiUrl}${uriEnd}${queryParams}" "${argumentValues}""
if [[ ${uriEnd} =~ "{" || ${queryParams} =~ "{" || ${argumentValues} =~ "{" ]]; then
    . $(dirname ${0})/curlsh.sh "${apiUrl}${uriEnd}${queryParams}" ""
    exit 1
fi
. $(dirname ${0})/curlsh.sh "${apiUrl}${uriEnd}${queryParams}" "${argumentValues}"
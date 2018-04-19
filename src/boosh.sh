#!/bin/bash

# Display formatting
B=$(tput bold)
N=$(tput sgr0)
U=$(tput smul)

# Option checks
function init() {
    validOption=0
    when=""
    dir="$(dirname ${0})"
    apiOutput=""
}

function initResult() {
    result=""
}

init
# Usage sourcing
. $(dirname ${0})/usage.sh

# allocate the arguments
function allocate() {
    arguments=${@}
    if [[ ! $(tr ' ' '\n' <<< "${@}" | awk '/when/{getline;print;}') = "" ]]; then
        when=$(echo ${arguments} | awk -F"when" '{print $2}')
        whenWithWhen="when $(echo $(echo ${arguments} | awk -F"when" '{print $2}'))"
        arguments="${arguments/${whenWithWhen}/}"
        # when=$(tr ' ' '\n' <<< "${@}" | awk '/when/{getline;print;}')
        # arguments=$(echo ${arguments} | sed "s|when ${when}||g")
    fi
}

# Manupulating the options given
function commandCheck() {
    commands=$(echo "${1}" | cut -d ':' -f '1')
    commandValid=$(cat ${dir}/config/curlsh.json | jq 'has("'${commands}'")')
    if [[ ${commandValid} = "true" ]]; then validOption=1; allocate ${@}; else usage; fi
}

# Make a bamboo call if valid options are given
function executeMain() {
    resVar=${1}
    echo "Main variable: ${resVar}"
    if [[ ${validOption} == 1 ]]; then 
        # . $(dirname ${0})/subCmd/bambooCalls.sh "${arguments}"; 
        echo A: ${arguments}
        echo W: ${when}
        if [[ ! "${when}" = "" ]]; then
            apiOutput=$(. $(dirname ${0})/subCmd/apiCalls.sh "${arguments}" "${when}")
            echo "Api Output: ${apiOutput}"
            echo "eval \"${resVar}\"=\"${apiOutput}\""
            eval "${resVar}"="${apiOutput}"
        else
            apiOutput=$(. $(dirname ${0})/subCmd/apiCalls.sh "${arguments}") 
            # echo "${apiOutput}"
            echo "Api Output: ${apiOutput}"
            # result="${apiOutput}"
            echo "eval \"${resVar}\"=\"${apiOutput}\""
            eval "${resVar}"="${apiOutput}"
        fi
    else
        usage; 
        exit 1
    fi
}

# check if then is given
if [[ $# -gt 0 ]]; then
    ln=0
    thenCheck="$(echo -e "${@}" | sed -e "s/ next /,/g" | tr "," "\n")"
    # echo ${thenCheck}
    echo "${thenCheck}" | while read cmd; do
        init
        (( ln++ ))
        # variableName="result_${ln}"
        (( ln-- )); variableName="result_${ln}"; (( ln++ ))
        if [[ ! "${!variableName}" = "" ]]; then
            # (( ln-- )); variableName="result_${ln}"; (( ln++ ))
            echo "cmd=\"${cmd/=store/=${!variableName}}\""
            cmd="${cmd/=store/=${!variableName}}"
            variableName="result_${ln}"
        fi
        variableName="result_${ln}"
        if [[ ! "${cmd}" = "store" ]]; then
            initResult
            commandCheck ${cmd}
            executeMain "${variableName}"
        else
            (( ln-- )); variableName="result_${ln}"; (( ln++ ))
            echo "${variableName}: ${!variableName}"
        fi
    done
else
    usage
    exit 1
fi
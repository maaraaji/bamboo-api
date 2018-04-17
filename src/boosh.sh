#!/bin/bash

# Display formatting
B=$(tput bold)
N=$(tput sgr0)
U=$(tput smul)

# Option checks
validOption=0
when=""
dir="$(dirname ${0})"

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

# check if then is given
if [[ $# -gt 0 ]]; then
    thenCheck=$(echo ${1} | awk -F"then" '{print')

# Manupulating the options given
if [[ $# -gt 0 ]]; then
    commands=$(echo "${1}" | cut -d ':' -f '1')
    commandValid=$(cat ${dir}/config/curlsh.json | jq 'has("'${commands}'")')
    if [[ ${commandValid} = "true" ]]; then validOption=1; allocate ${@}; else usage; fi
else
    usage
    exit 1
fi
# Make a bamboo call if valid options are given
if [[ ${validOption} == 1 ]]; then 
    # . $(dirname ${0})/subCmd/bambooCalls.sh "${arguments}"; 
    echo A: ${arguments}
    echo W: ${when}
    if [[ ! "${when}" = "" ]]; then
        . $(dirname ${0})/subCmd/apiCalls.sh "${arguments}" "${when}";
    else
        . $(dirname ${0})/subCmd/apiCalls.sh "${arguments}"; 
    fi
else
    usage; 
    exit 1
fi
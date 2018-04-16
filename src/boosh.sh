#!/bin/bash

# Display formatting
B=$(tput bold)
N=$(tput sgr0)
U=$(tput smul)

# Option checks
validOption=0

# Usage sourcing
. $(dirname ${0})/usage.sh

# allocate the arguments
function allocate() {
    arguments=${@}
}

# Manupulating the options given
if [[ $# -gt 0 ]]; then
    commands=$(echo "${1}" | cut -d ':' -f '1')
    commandValid=$(cat $(pwd)/config/curlsh.json | jq 'has("'${commands}'")')
    if [[ ${commandValid} = "true" ]]; then validOption=1; allocate ${@}; else usage; fi
else
    usage
    exit 1
fi
# Make a bamboo call if valid options are given
if [[ ${validOption} == 1 ]]; then 
    # . $(dirname ${0})/subCmd/bambooCalls.sh "${arguments}"; 
    . $(dirname ${0})/subCmd/apiCalls.sh "${arguments}"; 
else
    usage; 
    exit 1
fi
#!/bin/bash

# Display formatting
B=$(tput bold)
N=$(tput sgr0)
U=$(tput smul)

# Option checks
validOption=0

# Arguments initialization
callName="null"
callMethod="null"


# Usage function
function usage() {
    echo "Ask something to Bamboo buddy! Yethavathu kezhu machi!"
}

# allocate the arguments
function allocate() {
    callName=${1}
    callMethod=${2}
}

# Manupulating the options given
if [[ $# -gt 0 ]]; then
    case ${1} in
        dvs)    validOption=1; allocate ${@}  ;;
        *)  validOption=0   ;;
    esac
else
    usage
fi

# Make a bamboo call if valid options are given
if [[ ${validOption} == 1 ]]; then . $(dirname ${0})/subCmd/bambooCalls.sh "${callName} ${callMethod}"; else usage; fi
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

# Usage sourcing
. $(dirname ${0})/usage.sh

# allocate the arguments
function allocate() {
    callMethod=${1}
    callName=${2}
    callInMethod=${3}
    callInName=${4}
}

# Manupulating the options given
if [[ $# -gt 0 ]]; then
    case ${1} in
        dvs)    validOption=1; allocate ${@}    ;;
        search) validOption=1; allocate ${@}    ;;
        *)  usage  ;;
    esac
else
    usage
    exit 1
fi

# Make a bamboo call if valid options are given
if [[ ${validOption} == 1 ]]; then 
    . $(dirname ${0})/subCmd/bambooCalls.sh ${callMethod} ${callName} ${callInMethod} ${callInName}; 
else
    usage; 
    exit 1
fi
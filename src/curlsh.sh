#!/bin/bash

# Variables
apiOutput=""
jqParam="${2}"
dir="$(dirname ${0})"

# Usage sourcing
. $(dirname ${0})/usage.sh

# Get the username
getPassname=$(cat ${dir}/config/boosh.json | jq -r '.credentials.passname')
passname=$(echo "${getPassname}" | sed "s|{BAMBOO_USERNAME}|${BAMBOO_USERNAME}|g")
# echo ${passname}

# Get the password
getPassword=$(cat ${dir}/config/boosh.json | jq -r '.credentials.password')
password=$(echo "${getPassword}" | sed "s|{BAMBOO_PASSWORD}|${BAMBOO_PASSWORD}|g")
# echo ${password}

# Get the Bamboo URL
getBambooUrl=$(cat ${dir}/config/boosh.json | jq -r '.url.bambooUrl')
bambooUrl=$(echo "${getBambooUrl}" | sed "s|{BAMBOO_URL}|${BAMBOO_URL}|g")
# echo ${bambooUrl}

# Get the Bamboo Port
getBambooPort=$(cat ${dir}/config/boosh.json | jq -r '.url.bambooPort')
bambooPort=$(echo "${getBambooPort}" | sed "s|{BAMBOO_PORT}|${BAMBOO_PORT}|g")
# echo ${bambooPort}

# API_Output
# echo "curl -s -k -u ${passname}:${password} http://${bambooUrl}:${bambooPort}/${1} | jq -r '${jqParam}'"
commandToGetApiOutput="$(curl -s -k -u ${passname}:${password} http://${bambooUrl}:${bambooPort}/${1} | jq -r "${jqParam}")"
# apiOutput=$(echo "$(curl -s -k -u ${passname}:${password} http://${bambooUrl}:${bambooPort}/${1})" | jq -r '${jqParam}')
apiOutput="$(echo ${commandToGetApiOutput})"

#Check if it has errors
haveErrors=$(echo ${apiOutput} | jq 'has("errors")' 2>/dev/null)
# Print appropriate output
if [[ "${apiOutput}" = "null" || "${apiOutput}" = "" ]]; then usage; exit 1;
elif [[ "${haveErrors}" = "true" ]]; then
    echo ${apiOutput} | jq -r '.errors[]'
else echo ${apiOutput}; fi



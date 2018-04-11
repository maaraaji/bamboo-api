#!/bin/bash

# Get the username
getPassname=$(cat $(pwd)/config/boosh.json | jq -r '.credentials.passname')
passname=$(echo "${getPassname}" | sed "s|{BAMBOO_USERNAME}|${BAMBOO_USERNAME}|g")
# echo ${passname}

# Get the password
getPassword=$(cat $(pwd)/config/boosh.json | jq -r '.credentials.password')
password=$(echo "${getPassword}" | sed "s|{BAMBOO_PASSWORD}|${BAMBOO_PASSWORD}|g")
# echo ${password}

# Get the Bamboo URL
getBambooUrl=$(cat $(pwd)/config/boosh.json | jq -r '.url.bambooUrl')
bambooUrl=$(echo "${getBambooUrl}" | sed "s|{BAMBOO_URL}|${BAMBOO_URL}|g")
# echo ${bambooUrl}

# Get the Bamboo Port
getBambooPort=$(cat $(pwd)/config/boosh.json | jq -r '.url.bambooPort')
bambooPort=$(echo "${getBambooPort}" | sed "s|{BAMBOO_PORT}|${BAMBOO_PORT}|g")
# echo ${bambooPort}

# API_Output
echo "$(curl -s -k -u ${passname}:${password} http://${bambooUrl}:${bambooPort}/${1})"



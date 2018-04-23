#!/bin/bash

dir="$(dirname ${0})"
# dir="/Users/gk/GK/GURU/Open_Source/getrest/src"
. "${dir}/usage.sh"

function isCommandStore() {
    local validateThis=${@}
    if [[ "${validateThis}" = "store" ]]; then
        if [[ ! "${apiOutput}" = "" && ! "${apiOutput}" =~ "{" ]]; then
            storeResult
        fi
        return 0
    else
        return 1
    fi
}

function substituteStore() {
    local substituteAt="${1}"
    local withThis=$(echo "${2}" | tr -d '"')
    finalArgument=$(echo ${substituteAt} | sed "s|=store|=${withThis}|g")
}

function commandValidation() {
    local validateThis="$(echo ${1} | cut -d ":" -f 1)"
    local isValid=$(cat ${dir}/config/curlsh.json | jq 'has("'${validateThis}'")')
    if [[ ! "${isValid}" = "true" ]]; then usage; exit 1; fi
}

function allocate() {
    local allocateThis="${@}"
    if [[ ! $(tr " " "\n" <<< "${allocateThis}" | awk '/when/{getline;print;}') = "" ]]; then
        when=$(echo ${allocateThis} | awk -F"when" '{print $2}')
        local whenWithWhen="when $(echo $(echo ${allocateThis} | awk -F"when" '{print $2}'))"
        allocatedValue="${allocateThis/${whenWithWhen}/}"
    else
        allocatedValue="${allocateThis}"
    fi
}

function executeMain() {
    local currentApiOutput=$(. ${dir}/subCmd/apiCalls.sh "${allocatedValue}" "${when}")
    storeApiOutput "${currentApiOutput}"
}

function storeApiOutput() {
    local currentApiOutput="${1}"
    if [[ ! "${apiOutput}" = "" ]]; then
        apiOutput="${apiOutput};${currentApiOutput}"
    else
        apiOutput="${currentApiOutput}"
    fi
}

function storeResult() {
    result="$( echo ${apiOutput} | tr ";" "\n")"
    echo "Result: ${result}"
    numberOfSubstitutions=$(echo ${result} | wc -w )
}

function flow() {
    argument=${@}
    [[ "${argument}" =~ "store" ]]
    if [[ "${?}" = 0 ]]; then
        while read res; do
            substituteStore "${argument}" "${res}"
            echo "Commands to Process with substitute: ${finalArgument}"
            commandValidation ${finalArgument}
            allocate ${finalArgument}
            executeMain ${finalArgument}
        done <<< "$(echo ${result} | tr ' ' '\n')"
    else
        commandValidation ${cmd}
        allocate ${cmd}
        executeMain ${cmd}
    fi
}

if [[ $# -gt 0 ]]; then
commandNumber=0
allCommands="$(echo ${@} | sed -e 's| next |,|g')"
while read cmd; do
    # echo "Command : ${cmd}"
    isCommandStore ${cmd}
    if [[ "${?}" -eq 1 ]]; then
        flow ${cmd}
    fi
done <<EOF 
$(echo ${allCommands} | tr "," "\n")
EOF
echo "Final Result: ${apiOutput}"
fi
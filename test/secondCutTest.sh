#!/bin/bash

s="../src/boosh.sh"

function Heading() {
    echo "*********************** TEST: ${1}"
}
function Footer() {
    echo
}

# testCases="${s} projects:brief=plans end=BB: inProjects getShortName when planKey=BB-BBTES
# ${s} projects:brief=plans end=BB: inProjects getShortName when planKey=BB-BB2
# ${s} search plans:search=BB:
# ${s} search plans howMany
# ${s} search plans inPlans getProjectName when planName=bb2
# ${s} search plans inPlans getPlanName when description=
# ${s} search plans inPlans getPlanName when description=\"bb test build\""
# testCases="${s} projects:which=BB max=2 brief=plans: how many plans
# ${s} projects how many projects"




echo "${testCases}" | while read -r a; do
    Heading "${a}"
    ${a} | while read -r b; do if [[ ${b} =~ "{" ]]; then echo ${b} | jq; else echo ${b}; fi; done
    Footer
done
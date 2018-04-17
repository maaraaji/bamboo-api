#!/bin/bash

s="../src/boosh.sh"

function Heading() {
    echo "*********************** TEST: ${1}"
}
function Footer() {
    echo
}

# testCases="${s} projects:brief=plans which=BB: inProjects getShortName when planKey=BB-BBTES next projects:brief=plans which=BB: inProjects getShortName when planKey=BB-BB2 next search plans:search=BB: next search plans howMany next search plans inPlans getProjectName when planName=bb2 next search plans inPlans getPlanName when description= next search plans inPlans getPlanName when description=\"bb test build\" next projects:which=BB max=2 brief=plans: how many plans"
testCases="${s} projects:brief=plans which=BB: inProjects getShortName when planKey=BB-BBTES next projects:brief=plans which=BB: inProjects getShortName when planKey=BB-BB2"




echo "${testCases}" | while read -r a; do
    Heading "${a}"
    ${a} | while read -r b; do if [[ ${b} =~ "{" ]]; then echo ${b} | jq; else echo ${b}; fi; done
    Footer
done
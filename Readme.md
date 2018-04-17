# Manipulation of REST API using shell.
---
No more worries about issuing curl with jq all the times. No more the worries of creating a new script or existing script if the new version of REST API is released.
No more worries of getting information for your Chatbot through REST API and modify your script to manupulate it. Just update the JSON and call our Script it will do the job for you. Update the JSON programmatically if you are lazy enough to write it manually!

### Prerequisites

Requirements | Description
---|---
|/bin/bash| This tool is designed predominently to work on bash
|jq| for pasing json|

#### ***curlsh.json*** Terminologies
1. Objects inside the **uri** configured object are referring to the json outputs filter
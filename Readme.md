# Manipulation of REST API using shell.
---
No more worries about issuing curl with jq all the times. No more the worries of creating a new script or existing script if the new version of REST API is released.
No more worries of getting information for your Chatbot through REST API and modify your script to manupulate it. Just update the JSON and call our Script it will do the job for you. Update the JSON programmatically if you are lazy enough to write it manually!

### Prerequisites

Requirements | Description
---|---
|/bin/bash| This tool is designed predominently to work on bash
|jq| for pasing json|

## **Reservations**
1. ***curlsh.json*** Reservations

Reserved Keys | Description
---|---
uri | REST URI to curl for information
query.after | URL parameters to consider while constructing the curl command
query.end : "true" or "false" | If the parent REST URI have to be end with a dynamic value make it true
when | If you want to filter the resulting JSON matching the value in specific key

2. ***Command Line*** Reservations

Reserved Keys | Description
---|---
`"first command" then "second command"` | to process multiple commands in a single line where the output of the first command will be utilized in second command

# Manipulation of REST API using shell.
---
No more worries of issuing `curl` with `jq` all the times. No more the worries of creating a new script or modifying existing script if the new version of REST API is released.

Implementing a **`ChatBot`** that rely on REST input will be super easy. Talk to your chatbot like you talk with others. Just update the conversational sentences in a JSON as objects within objects and call our Script, it will do the job for you. Update the JSON programmatically if you are lazy enough to write it manually!

---
### Prerequisites

Requirements | Description
---|---
|/bin/bash| This tool is designed predominently to work on bash
|jq| for pasing json|

---

### **Reservations**
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

#!/bin/bash
set -e
#git clone https://github.com/{{inputs.parameters.repo_owner}}/{{inputs.parameters.repo_name}}.git
#cd {{inputs.parameters.repo_name}}
MSG=$(echo '{"data":"eyAicGFja2V0cyI6IFsiYXBwMSIsImFwcDIiXX0K"}' | jq -r .data | base64 -d)
PACKETS=$(echo $MSG | jq -r '.packets[]')
echo $PACKETS
IFS=$'\n'
while read -r packet; do
  modified=$(git log --format= -n 1 --name-only | egrep "^go/$packet" | wc -l)
  echo $packet $modified
done <<< "$PACKETS"
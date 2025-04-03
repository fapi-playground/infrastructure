#!/bin/sh

# all the filenames in hydra/clients (without extension) MUST match with client_id json field in file
for client_id in $(find /clients -type f -name "*.json" | sed -r "s/.+\/(.+)\..+/\1/")
	do
    if ! hydra list clients --format=json --endpoint=http://hydra:4445 | jq -r .items | jq -e ".[] | select (.client_id==\"$client_id\")" > /dev/null; then
      hydra import client /clients/$client_id.json --endpoint http://hydra:4445
    fi
	done



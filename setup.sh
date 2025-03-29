#!/bin/bash

set -e
#set -x

# set up data & secrets dir with the right ownerships in the default location
# to stop docker autocreating them with random owners.
# originally these were checked into the git repo, but that's pretty ugly, so doing it here instead.
mkdir -p data/{element-web,postgres,synapse,hydra,kratos}
mkdir -p secrets/{postgres,synapse,hydra,kratos}

# create blank secrets to avoid docker creating empty directories in the host
touch secrets/postgres/postgres_password \
      secrets/synapse/signing.key \
      secrets/synapse/client_id \
      secrets/hydra/system_secret \
      secrets/hydra/pairwise_salt \
      secrets/kratos/cookie_secret \
      secrets/kratos/cipher_secret

# grab an env if we don't have one already
if [[ ! -e .env  ]]; then
    cp .env-sample .env

    sed -ri.orig "s/^USER_ID=/USER_ID=$(id -u)/" .env
    sed -ri.orig "s/^GROUP_ID=/GROUP_ID=$(id -g)/" .env

    read -p "Enter base domain name (e.g. example.com): " DOMAIN
    sed -ri.orig "s/example.com/$DOMAIN/" .env
    
    read -p "Enter smtp2go login: " SMTP2GO_USER 
    sed -ri.orig "s/smtp2go.user/$SMTP2GO_USER/" .env

    read -p "Enter smtp2go password: " SMTP2GO_PASS 
    sed -ri.orig "s/smtp2go.pass/$SMTP2GO_PASS/" .env

else
    echo ".env already exists; move it out of the way first to re-setup"
fi


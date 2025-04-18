#!/bin/bash

set -e
#set -x

# basic script to generate templated config for our various docker images.
# it runs in its own alpine docker image to pull in yq as a dep, and to let the whole thing be managed by docker-compose.

# by this point, synapse & mas should generated default config files & secrets
# via generate-synapse-secrets.sh and generate-mas-secrets.sh

if [[ ! -s /secrets/synapse/signing.key ]] # TODO: check for existence of other secrets?
then
	# extract synapse secrets from the config and move them into ./secrets
	echo "Extracting generated synapse secrets..."
	mkdir -p /secrets/synapse
	for secret in registration_shared_secret macaroon_secret_key form_secret
	do
		yq .$secret /data/synapse/homeserver.yaml.default > /secrets/synapse/$secret
	done
	# ...and files too, just to keep all our secrets in one place
	mv /data/synapse/${DOMAIN}.signing.key /secrets/synapse/signing.key
fi


# TODO: compare the default generated config with our templates to see if our templates are stale
# we'd have to strip out the secrets from the generated configs to be able to diff them sensibly

# now we have our secrets extracted from the default configs, overwrite the configs with our templates

# for simplicity, we just use envsubst for now rather than ansible+jinja or something.
template() {
	dir=$1
	echo "Templating configs in $dir"
	for file in `find $dir -type f`
	do
		mkdir -p `dirname ${file/-template/}`
		envsubst < $file > ${file/-template/}
	done
}

export DOLLAR='$' # evil hack to escape dollars in config files
(
	export SECRETS_SYNAPSE_REGISTRATION_SHARED_SECRET=$(</secrets/synapse/registration_shared_secret)
	export SECRETS_SYNAPSE_MACAROON_SECRET_KEY=$(</secrets/synapse/macaroon_secret_key)
	export SECRETS_SYNAPSE_FORM_SECRET=$(</secrets/synapse/form_secret)
	export SECRETS_POSTGRES_PASSWORD=$(</secrets/postgres/postgres_password)
	template "/data-template/synapse"
)

template "/data-template/element-web"
template "/data-template/nginx"

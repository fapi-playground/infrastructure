#!/bin/bash

set -e
#set -x

# basic script to generate templated config for our various docker images.
# it runs in its own alpine docker image to pull in yq as a dep, and to let the whole thing be managed by docker-compose.

if [[ ! -s /secrets/postgres/postgres_password ]]
then
	mkdir -p /secrets/postgres
	tr -dc 'A-Za-z0-9' </dev/urandom | head -c32 > /secrets/postgres/postgres_password
fi

if [[ ! -s /secrets/kratos/cookie_secret ]]
then
	mkdir -p /secrets/kratos
	tr -dc 'A-Za-z0-9' </dev/urandom | head -c32 > /secrets/kratos/cookie_secret
fi

if [[ ! -s /secrets/kratos/cipher_secret ]]
then
	mkdir -p /secrets/kratos
	tr -dc 'A-Za-z0-9' </dev/urandom | head -c32 > /secrets/kratos/cipher_secret
fi

if [[ ! -s /secrets/hydra/system_secret ]]
then
	mkdir -p /secrets/hydra
	tr -dc 'A-Za-z0-9' </dev/urandom | head -c32 > /secrets/hydra/system_secret
fi

if [[ ! -s /secrets/hydra/system_secret ]]
then
	mkdir -p /secrets/hydra
	tr -dc 'A-Za-z0-9' </dev/urandom | head -c32 > /secrets/hydra/system_secret
fi

if [[ ! -s /secrets/hydra/pairwise_salt ]]
then
	mkdir -p /secrets/hydra
	tr -dc 'A-Za-z0-9' </dev/urandom | head -c32 > /secrets/hydra/pairwise_salt
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
  export SECRETS_POSTGRES_PASSWORD=$(</secrets/postgres/postgres_password)
  export SECRETS_KRATOS_COOKIE=$(</secrets/kratos/cookie_secret)
  export SECRETS_KRATOS_CIPHER=$(</secrets/kratos/cipher_secret)
  template "/data-template/kratos"
)

(
  export SECRETS_POSTGRES_PASSWORD=$(</secrets/postgres/postgres_password)
  export SECRETS_HYDRA_SYSTEM=$(</secrets/hydra/system_secret)
  export SECRETS_HYDRA_PAIRWISE_SALT=$(</secrets/hydra/pairwise_salt)
  template "/data-template/hydra"
)


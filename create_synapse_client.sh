code_client=$(docker compose exec hydra \
    hydra create client \
    --endpoint http://127.0.0.1:4445 \
    --grant-type authorization_code,refresh_token \
    --response-type code,id_token \
    --format json \
    --scope openid --scope profile --scope email \
    --redirect-uri https://matrix.gregs-homelab.com/_synapse/client/oidc/callback \
    --token-endpoint-auth-method none
    --skip-consent);
code_client_id=$(echo $code_client | jq -r '.client_id');
code_client_secret=$(echo $code_client | jq -r '.client_secret');
echo 'synapse client id: ';
echo $code_client_id;
echo 'synapse client secret: ';
echo $code_client_secret;

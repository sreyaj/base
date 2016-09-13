#!/bin/bash -e

export VAULT_ADDR=http://localhost:8200
export VAULT_KEYFILE=/etc/vault.d/keys.txt
export DB_USERNAME=$1
export DB_NAME=$2
export DB_IP=$3
export VAULT_IP=$4
export EXIT_CODE=0
export VAULT_TOKEN=""

status() {
  {
    vault status
  } || {
    export EXIT_CODE=$?
  }
}

init() {
  echo "Running 'vault init' to initialize Vault server"
  vault init | tee $VAULT_KEYFILE
}

unseal() {
  if [ ! -f "$VAULT_KEYFILE" ]; then
    echo "Missing key file: $VAULT_KEYFILE required to unseal vault"
    echo "run 'vault init | tee $VAULT_KEYFILE' manually to generate keyfile"
    exit 1
  else
    echo "Vault key file $VAULT_KEYFILE exists, unsealing vault"
    KEY_1=$(grep 'Key 1:' $VAULT_KEYFILE | awk '{print $NF}')
    KEY_2=$(grep 'Key 2:' $VAULT_KEYFILE | awk '{print $NF}')
    KEY_3=$(grep 'Key 3:' $VAULT_KEYFILE | awk '{print $NF}')

    vault unseal "$KEY_1"
    vault unseal "$KEY_2"
    vault unseal "$KEY_3"
  fi
}

update_vault_token() {
  local vault_config_file="/etc/vault.d/vaultConfig.json"

  VAULT_TOKEN=$(grep 'Initial Root Token:' $VAULT_KEYFILE | awk '{print substr($NF, 1, length($NF))}')

  sed -i "s/{{VAULT_TOKEN}}/$VAULT_TOKEN/g" $vault_config_file
}

auth() {
  vault auth "$VAULT_TOKEN"
}

mount_shippable() {
  vault mount -path=shippable generic
}

write_policy() {
  vault policy-write shippable /etc/vault.d/policy.hcl
}

main() {
  status
  if [ $EXIT_CODE -eq 0 ]; then
    ## vault running correctly
    echo "Vault server running in unsealed state"
    update_vault_token
  elif [ $EXIT_CODE -eq 2 ]; then
    ## vault running but in sealed state
    echo "Vault server running in sealed state"
    unseal
    update_vault_token
  else
    ## error
    echo "Initializing vault server"
    init
    unseal
    update_vault_token
    auth
    mount_shippable
    write_policy
  fi
}

main

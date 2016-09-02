export VAULT_ADDR=http://0.0.0.0:8200
export VAULT_KEYFILE=/etc/vault.d/keys.txt
export DB_USERNAME=$1
export DB_NAME=$2
export DB_IP=$3
export VAULT_IP=$4


status() {
  vault status
  export EXIT_CODE=$?
}

check_keyfile_exists() {
  if [ -f $VAULT_KEYFILE ]; then
    # KEY FILE PRESENT
    # 1 - error
    if [ $EXIT_CODE -eq 1 ]; then
      init
      unseal
      auth
      mount_shippable
      write_policy
    # 2 - sealed
    else
      unseal
    fi
  else
    # KEY FILE NOT PRESENT
    run_vault_migration
    init
    unseal
    auth
    mount_shippable
    write_policy
  fi
}

run_vault_migration() {
  psql -U $DB_USERNAME -d $DB_NAME -h $DB_IP -c "drop table if exists vault_kv_store"
  psql -U $DB_USERNAME -h $DB_IP -d $DB_NAME -w -f /etc/vault.d/vault.sql
  sudo service vault restart
  sleep 5
}

init() {
  vault init | sudo tee $VAULT_KEYFILE
}

unseal() {
  KEY_1=$(grep 'Key 1:' $VAULT_KEYFILE | awk '{print $NF}')
  KEY_2=$(grep 'Key 2:' $VAULT_KEYFILE | awk '{print $NF}')
  KEY_3=$(grep 'Key 3:' $VAULT_KEYFILE | awk '{print $NF}')

  vault unseal $KEY_1
  vault unseal $KEY_2
  vault unseal $KEY_3

  copy_vault_config
}

copy_vault_config() {
  local VAULT_URL=$VAULT_IP":8200"
  local vault_config_file="/vault/config/scripts/vaultConfig.json"

  VAULT_TOKEN=$(grep 'Initial Root Token:' $VAULT_KEYFILE | awk '{print substr($NF, 1, length($NF))}')

  touch $vault_config_file
  cat /vault/config/scripts/vaultConfig.json.template > $vault_config_file
  sed -i "s/{{VAULT_URL}}/$VAULT_URL/g" $vault_config_file
  sed -i "s/{{VAULT_TOKEN}}/$VAULT_TOKEN/g" $vault_config_file
}

auth() {
  vault auth $VAULT_TOKEN
}

mount_shippable() {
  vault mount -path=shippable generic
}

write_policy() {
  vault policy-write shippable /etc/vault.d/policy.hcl
}

main() {
  status
  # 0 - Success
  if [ $EXIT_CODE -eq 0 ]; then
    return
  else
    check_keyfile_exists
  fi
}

main

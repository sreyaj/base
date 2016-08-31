export VAULT_ADDR=http://0.0.0.0:8200
export VAULT_KEYFILE=/etc/vault.d/keys.txt
export DB_USERNAME=$1
export DB_NAME=$2
export DB_IP=$3


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
      insert_system_integrations
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
    insert_system_integrations
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

  VAULT_TOKEN=$(grep 'Initial Root Token:' $VAULT_KEYFILE | awk '{print substr($NF, 1, length($NF))}')
  touch /vault/config/scripts/system_config.sql
  sed -e "s/INSERTTOKENHERE/$VAULT_TOKEN/g" /vault/config/scripts/system_config.sql.template >  /vault/config/scripts/system_config.sql
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

insert_system_integrations() {
  ##TODO: read these values from state.json
  vault write shippable/systemIntegrations/574ee745d49b091400b76273 @/vault/data/gitlab.json
  vault write shippable/systemIntegrations/574ee745d49b091400b76274 @/vault/data/github.json
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

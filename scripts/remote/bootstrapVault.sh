export VAULT_ADDR=http://0.0.0.0:8200
export VAULT_KEYFILE=/etc/vault.d/keys.txt

status() {
  vault status
  export EXIT_CODE=$?
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
  #vault write shippable/systemIntegrations/574ee745d49b091400b76273 @gitlab.json
  #vault write shippable/systemIntegrations/574ee745d49b091400b76274 @github.json
  true
}

main() {
  status
  # 0 - Success
  if [ $EXIT_CODE -eq 0 ]; then
    return
  # 1 - Error
  elif [ $EXIT_CODE -eq 1 ]; then
    init
    unseal
    auth
    mount_shippable
    write_policy
    insert_system_integrations
  # 2 - Sealed
  else
    unseal
  fi
}

main

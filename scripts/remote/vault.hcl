backend "postgresql" {
  connection_url = "postgres://{{DB_USERNAME}}:{{DB_PASSWORD}}@{{DB_ADDRESS}}/shipdb?sslmode=disable"
}

listener "tcp" {
  address = "0.0.0.0:8200"
  tls_disable = 1
}

max_lease_ttl = "720h"


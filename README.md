# Base
Shippable Enterprise Installer

## Configuring

### Configure data/machines.json
* `cp data/machines.json.example data/machines.json`
* Update the `data/machines.json` file with the instance details.

### Configure data/confg.json
* `cp data/config.json.example data/config.json`
* Update the `data/config.json` file with the config.

### Configuring Proxy
If you're running the installer behind a proxy, you will need to update the following:
* `/etc/environment` with `HTTP_PROXY`, `HTTPS_PROXY`, `http_proxy`, `https_proxy`
* `/etc/default/docker` with `http_proxy`

### Installing

* Run `sudo -E ./base.sh -i`

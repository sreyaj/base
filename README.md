# Base
Shippable Enterprise Installer

## Configuring

### Configure data/machines.json
* `cp data/machines.json.example data/machines.json`
* Update the `data/machines.json` file with the instance details.

### Configure data/config.json
* `cp data/config.json.example data/config.json`
* Update the `data/config.json` file with the config.

#### Configuring Providers
* The `providers`, `systemIntegrations` section will need to be updated for configuring providers.
* For Github, and Bitbucket the `providers` section can be left empty.
* For Github Enterprise, and Bitbucket Server/Stash -- Update the provider url with your instance's URL. The rest can be left as-is.
* In the systemIntegration section, pick the example configuration that you want for the provider. The rest can be removed. Only the `formJSONValues` will need to be updated as per your provider configuration. Here, the `providerId` can be left as-is(it maps to the provider we added earlier).

### Configuring Proxy
If you're running the installer behind a proxy, you will need to update the following:
* `/etc/environment` with `HTTP_PROXY`, `HTTPS_PROXY`, `http_proxy`, `https_proxy`
* `/etc/default/docker` with `http_proxy`

### Installing

* Run `sudo -E ./base.sh -i`

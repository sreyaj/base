# upgrading guidelines

The installer supports upgrading the components to a new release version. This can be done by simply running the installer again with a different flag and cli arguments.

## Updating just the microservices  

To just update the microservices to a new release, say, `v4.11.2` run the following command

```
./base.sh --release v4.11.2
```

The installer then
  - re-authenticates with the registry
  - creates a new service with the provided version
  - starts the service
When this step is complete, all the microservices will run with the upgraded version


## Updating system settings

To update one(or more) system settings, just change the desired values in `usr/state.json` and re-run the installer with current release version.

```
./base.sh --release v4.11.2
```

## Updating master integrations

All the master integrations are inserted in the database when the migration script is run the first time but none of these integrations are enabled by default. To enable an integration, there needs to be an entry for integration in state file. For example, to enable login from github, the following object needs to be added to `masterIntegrations` array.

```
    {
      "name": "github",
      "type": "auth"
    }
```

and to enable github as an scm provider, the following needs to be added

```
    {
      "name": "github",
      "type": "scm"
    }
```

Adding these values in state file and running installer again, will set the `isEnabled` flag for these integrations to `true` in the database. So, for any installation, the list of all master integration that are enabled should be provided in the `masterIntegrations` array in `usr/state.json`. The database should never be altered manually.
Similarly, to disable a `masterIntegration`, just remove it from the list and run installer again. This will set `isEnabled` flag to false in database for that integration.

## Updating system integrations

A system integration can only be enabled if the corresponding `masterIntegration` is enabled. A `systemIntegration` is enabled the same way as a master integrations. The values have to be added in the `systemIntegrations` array in state file at `usr/state.json`. e.g. to add credentials for `github` master integration of type `auth`, add following values in `systemIntegrations` array

```
{
  "name": "github.com",
  "masterName": "github",
  "masterType": "auth",
  "formJSONValues": [
    {
      "label": "clientId",
      "value": "<github app client id>"
    },
    {
      "label": "clientSecret",
      "value": "<github app client secret id>"
    },
    {
      "label": "wwwUrl",
      "value": "http://localhost:50001"
    },
    {
      "label": "url",
      "value": "https://api.github.com"
    }
  ]
}
```

Adding these values in state file and running installer again, will set the `isEnabled` flag for these system integration to `true` in the database. It will also update the values of variables like `clientId`, `clientSecret` etc. So, for any installation, the data for system integrations is provided in `systemIntegrations` array in `usr/state.json`. The database should never be altered manually.
Similarly, to disable a `systemIntegration`, just remove it from the list and run installer again.

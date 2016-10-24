# `production` installation mode

This doc lists the steps to install Shippable on custom infrastructure. The installer can
be configured to install SASS version or in Server version. Other than a few configuration 
settings and flags, both the versions are exactly the same and **always** run the same 
version of code

## Common steps for setting up SASS and Server versions

### Get the installer
- `ssh` into the `manager` machine

- install `git` using following
```
$ sudo apt-get install git-core
```

- clone the installer
```
$ git clone https://github.com/Shippable/base.git
$ cd base
```

- checkout release version, if only a specific release needs to be installed. 
Installer releases are listed [here](https://github.com/Shippable/base/releases)
``
$ git checkout <release_version>
```

### Configure machines  

- copy `usr/machines.json.example` to `usr/machines.json`
- edit the username and ip addresses of the machines
- more machines can be added for `group:services`. This just means additional machines will be 
  configured for running microservices

### Run installer  

- run the following command to start installer  
```
$ ./base.sh --install production
```

### Copy Keys

- Since this is the first time installer is running, it'll ask the user to copy the ssh key
into all the machines in the topology.
- the user will need to `Ctrl-c` the installer to add the key on the `manager` machine also

### Update configuration  

- This steps is to configure the `usr/state.json` file. The user need not update all the variables
here, just a few settings need to be changes. These are listed below:  
  ```
  systemSettings.serverEnabled    // to install in SASS mode or Server mode
  systemSettings.apiUrl           // should be the internet-routable api lb address
  systemSettings.wwwUrl           // should be the internet-routable UI lb address
  systemSettings.amqpUrl          // should be internet routable message queue address
  systemSettings.amqpUrlRoot      // should be internet routable message queue root vhost
  systemSettings.amqpUrlAdmin     // should be internet routable message queue admin address
  systemSettings.installerAccessKey // ECR access key to pull Shippable images from
  systemSettings.installerSecretKey // ECR secret key to pull Shippable images from
  ```

### Run installer
- run the following command to start installer again
```
$ ./base.sh --install production
```

- this time, answer `y` to the prompt that asks for keys update
- once this is done, installer should do the following. Note that no user action is required
when the following steps are being executed
  - [all machines] check ssh accesss
  - [all machines] bootstrap to install required tools like `jq`
  - [core] install and configure database
  - [core] install and configure rabbitmq
  - [core] install and configure vault
  - [manager] install and configure gitlab
  - [manager] install and configure redis
  - [manager] install and configure docker
  - [manager] initialize as swarm master
  - [services] install docker
  - [services] initialize as swarm workers
  - [core] update shippable config in db
  - [manager] execute command to boot api

- once api boots, it the loadbalancer should automatically get healty status check. To manually
check if api is up or not, run following command

```
$ curl -XGET https://<api-loadbalancer-address>
{"status":"OK","body":{},"query":{},"params":{},"method":"GET"}
```

- the installer will run the version specific sql migration once api boots successfully and then
proceed to configuring integrations

### Configure Integrations  

- For the first run, there are no integrations set up by default, so the installer shows following message
when there are no integrations set up in system

```
... earlier logs 

|___ Please enable 'masterIntegrations' in state.json and run installer again
|___ List of available 'masterIntegrations'

          Master Integration Name       Type
----------------------------------------------
                              ACS     deploy
                      artifactory        hub
                              AWS     deploy
                              AWS cloudproviders
                          AWS_IAM     deploy
                        bitbucket        scm
                        bitbucket       auth
                  bitbucketServer       auth
                  bitbucketServer        scm
                        braintree    payment
                          CLUSTER     deploy
                              DCL     deploy
                              DDC     deploy
                           Docker        hub
          Docker Trusted Registry        hub
                              ECR        hub
                            Email notification
                              GCR        hub
                              ghe        scm
                           github       auth
                           github        scm
                 githubEnterprise       auth
                           gitlab        scm
                        Git store        scm
                              GKE     deploy
                            gmail notification
                          hipchat notification
                          Jenkins externalci
                          mailgun notification
                          pem-key        key
          Private Docker Registry        hub
                          Quay.io        hub
                               S3   artifact
                            Slack notification
                             SMTP notification
                          ssh-key        key
                           TRIPUB     deploy
                          webhook notification

```
- This is the global list of available master integrations. They need to be enabled in the `usr/state.json` file
to be used.
- As an example, we'll enable `github` login for SASS version and `bitbucketserver` for Server version.


### SASS version specific configuration

- for Server version integration configuration, skip to the next section
- Enable `masterIntegrations`
Edit `usr/state.json`. Edit the `masterIntegrations` array and change it to following  

```json
masterIntegrations: [
  {
    "name": "Git store",
    "type": "scm"
  },
  {
    "name": "github",
    "type": "auth"
  },
  {
    "name": "github",
    "type": "scm"
  }
]
```

Save and close.
Note that the `name` and `type` of any integration is the same as the ones provided in full master integration list

-  Enable `systemIntegrations`  
Edit `usr/state.json`. Edit the `systemIntegrations` array and change it to following

```
systemIntegrations: [
  {
    "name": "gitlab",
    "masterDisplayName": "Internal Gitlab Server",
    "masterName": "Git store",
    "masterType": "scm",
    "isEnabled": true,
    "formJSONValues": [
      {
        "label": "username",
        "value": "root"
      },
      {
        "label": "subscriptionProjectLimit",
        "value": "100"
      },
      {
        "label": "password",
        "value": "shippable1234"
      },
      {
        "label": "url",
        "value": "http://<manager-ip>/api/v3"
      },
      {
        "label": "sshPort",
        "value": "22"
      }
    ]
  },
  {
    "isEnabled": true,
    "formJSONValues": [
      {
        "value": "<github app client id>",
        "label": "clientId"
      },
      {
        "value": "<github app client secret>",
        "label": "clientSecret"
      },
      {
        "value": "<internet routable address of ui>",
        "label": "wwwUrl"
      },
      {
        "value": "https://api.github.com",
        "label": "url"
      }
    ],
    "masterType": "auth",
    "masterName": "github",
    "masterDisplayName": "github auth",
    "name": "github.com"
  }
]
```
Save and close.
Note that the `masterName` and `masterType` of the `systemIntegrations` are the same as the enabled
`masterIntegrations`


## Server version specific configuration

- Enable `masterIntegrations`  
Edit `usr/state.json`. Edit the `masterIntegrations` array and change it to following

```
masterIntegrations: [
  {   
    "name": "Git store",
    "type": "scm"
  },  
  {   
    "name": "bitbucketServer",
    "type": "auth"
  },  
  {   
    "name": "bitbucketServer",
    "type": "scm"
  }
]
```
Save and close.  
Note that the `name` and `type` of any integration is the same as the ones provided in full master integration list

-  Enable `systemIntegrations`  
Edit `usr/state.json`. Edit the `systemIntegrations` array and change it to following

```
systemIntegrations: [
  {
    "name": "gitlab",
    "masterDisplayName": "Internal Gitlab Server",
    "masterName": "Git store",
    "masterType": "scm",
    "isEnabled": true,
    "formJSONValues": [
      {
        "label": "username",
        "value": "root"
      },
      {
        "label": "subscriptionProjectLimit",
        "value": "100"
      },
      {
        "label": "password",
        "value": "shippable1234"
      },
      {
        "label": "url",
        "value": "http://<manager-ip>/api/v3"
      },
      {
        "label": "sshPort",
        "value": "22"
      }
    ]
  },
  {   
    "formJSONValues": [
      {
        "label": "clientSecret",
        "value": "<bitbucket server private key>"
      },
      {
        "label": "clientId",
        "value": "Shippable"
      },
      {
        "label": "url",
        "value": "<bitbucket server api url>:7990"
      },
      {
        "label": "wwwUrl",
        "value": "<internet routable address of ui> "
      }
    ],  
    "masterType": "auth",
    "masterName": "bitbucketServer",
    "name": "bitbucket server auth"
  }  
]
```
Save and close.
Note that the `masterName` and `masterType` of the `systemIntegrations` are the same as the enabled
`masterIntegrations`

### Run installer  

- integration configuration is the last manual step. Once this is done, run the installer again

- run the following command to start installer  
```
$ ./base.sh --install production
```

- This time, installer will do the following after booting up api
  - run migrations
  - enable all the `masterIntegrations` listed in the array
  - insert all the `systemIntegrations` listed in the array
  - restart api
  - start www
  - start other services


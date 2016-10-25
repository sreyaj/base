# `local` installation mode

## configuration
- for local testing, we can set up the system with just github login and scm provider. The `masterIntegrations`
and `systemIntegrations` can be set to following for the system to enable github login and running builds.


```
  "masterIntegrations": [
    {
      "name": "github",
      "type": "auth"
    },
    {
      "name": "github",
      "type": "scm"
    },
    {
      "name": "Git store",
      "type": "scm"
    },
    {
      "name": "AWS",
      "type": "cloudproviders"
    }
  ],
  "systemMachineImages": [
    {
      "subnetId": "subnet-123456",
      "securityGroup": "sg-123456",
      "runShImage": "shipimg/runsh:v4.11.3-alpha.47",
      "execImage": "shipimg/mexec:v4.11.3-alpha.47",
      "externalId": "ami-abcdefgh",
      "provider": "AWS",
      "description": "Stable AMI",
      "name": "Stable",
      "isAvailable": true,
      "isDefault": true,
      "region": "us-east-1",
      "keyName": "shippable-beta"
    }
  ],
  "systemIntegrations": [
    {
      "isEnabled": true,
      "formJSONValues": [
        {
          "label": "accessKey",
          "value": "testing"
        },
        {
          "label": "secretKey",
          "value": "testing"
        }
      ],
      "masterType": "cloudproviders",
      "masterName": "AWS",
      "masterDisplayName": "AWS-ROOT",
      "name": "AWS-ROOT"
    },
    {
      "name": "gitlab",
      "masterName": "Git store",
      "masterType": "scm",
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
          "value": "http://172.17.42.1/api/v3"
        },
        {
          "label": "sshPort",
          "value": "22"
        }
      ]
    },
    {
      "name": "github.com",
      "masterName": "github",
      "masterType": "auth",
      "formJSONValues": [
        {
          "label": "clientId",
          "value": "<github client id>"
        },
        {
          "label": "clientSecret",
          "value": "<github client secret>"
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
  ]
```

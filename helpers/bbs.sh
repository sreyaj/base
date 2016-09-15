#!/bin/bash -e

readonly DATA_DIR="../data"
readonly BBS_KEY="$DATA_DIR/bbs"

PROVIDER_ID=3

add_bbserver() {
  __process_msg "Do you want to add the Bitbucket Server integration? (y/n)"
  read response
  if [[ "$response" =~ "y" ]]; then
    __process_msg "Please enter the private IP for the Bitbucket Server(eg: http://127.0.0.1) : "
    read response
    local private_url=$response
    __process_msg "Please enter the public IP/URL for the Bitbucket Server(eg: http://bitbucketServer.com) : "
    read response
    local public_url=$response
    local id="57d293efeecf9c0f0016cf2c"

    local bbs_provider='{
        "id": "'$id'",
        "url": "'$private_url'",
        "providerId": '$PROVIDER_ID',
        "masterIntegrationId": "572af430ead9631100f7f64d",
        "name": "bitbucketServer",
        "createdAt": "2016-09-12T07:16:55.387Z",
        "updatedAt": "2016-09-12T08:04:18.893Z"
      }'

    __process_msg "Please enter the hostname(eg: ship.com) : "
    read response
    local host_name=$response
    __process_msg "Please enter the port(optional) : "
    read response
    local port=$response
    __process_msg "Please enter the protocol : "
    read response
    local protocol=$response
    __generate_ssh_key
    local bbs_ssh_key=""
    while read -r line || [[ -n "$line" ]]; do
      bbs_ssh_key=$bbs_ssh_key"$line\\r\\n"
    done < "$BBS_KEY"

    local bbserver_sys_integration='{
      "id": "507f191e810c19729de860ea",
      "name": "bitbucketServer",
      "masterDisplayName": "bitbucket server auth",
      "masterIntegrationId": "577de63321333398d11a35ae",
      "masterName": "bitbucketServer",
      "masterType": "auth",
      "formJSONValues": [
       {
        "label": "clientId",
        "value": "Shippable"
      },
      {
        "label": "clientSecret",
        "value": "'$bbs_ssh_key'"
      },
      {
        "label": "hostname",
        "value": "'$host_name'"
      },'
      if [ ! -z $port ]; then
        bbserver_sys_integration=$bbserver_sys_integration'
        {
          "label": "port",
          "value": "'$port'"
        },
        '
      fi
      bbserver_sys_integration=$bbserver_sys_integration'
      {
        "label": "protocol",
        "value": "'$protocol'"
      },
      {
        "label": "providerId",
        "value": "'$PROVIDER_ID'"
      },
      {
        "label": "requestTokenURL",
        "value": "'$private_url'/plugins/servlet/oauth/request-token"
      },
      {
        "label": "accessTokenURL",
        "value": "'$private_url'/plugins/servlet/oauth/access-token"
      },
      {
        "label": "userAuthorizationURL",
        "value": "'$public_url'/plugins/servlet/shippable-oauth/authorize"
      }
      ],
      "isEnabled": true
    }'


    __process_msg "Please add the following json to the providers array in the config.json file..."
    echo $bbs_provider | jq '.'

    __process_msg "Please add the following json to the systemIntegrations array in the config.json file..."
    echo $bbserver_sys_integration | jq '.'

    ((PROVIDER_ID++))
  fi
}

__generate_ssh_key() {
  __process_msg "Please generate a SSH key in the data folder, with the file name bbs"
  echo "     ssh-keygen -t rsa"
  echo "     can be used to generate the ssh key. Press (y) to continue..."
  read response
  if [[ "$response" =~ "y" ]]; then
    if [ ! -f "$BBS_KEY" ]; then
      __generate_ssh_key
    fi
  else
    __generate_ssh_key
  fi
}

__process_msg() {
  local message="$@"
  echo "|___ $@"
}

main() {
	add_bbserver
}

main

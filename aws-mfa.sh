#!/bin/bash

AWS_ACCESS_KEY_ID=""
AWS_SECRET_ACCESS_KEY=""
AWS_SESSION_TOKEN=""

static_profile="static"
login_profile="mgmt"

serial=$(aws --profile $static_profile iam list-mfa-devices --query MFADevices[0].SerialNumber | cut -d'"' -f2)

token="$(aws --profile $static_profile sts get-session-token --serial-number $serial --token-code $1)"

aws --profile $login_profile configure set aws_access_key_id $(echo "$token" | grep AccessKeyId | cut -d'"' -f4)
aws --profile $login_profile configure set aws_secret_access_key $(echo "$token" | grep SecretAccessKey | cut -d'"' -f4)
aws --profile $login_profile configure set aws_session_token $(echo "$token" | grep SessionToken | cut -d'"' -f4)

for account in $(grep '^\[profile' $HOME/.aws/config | cut -d']' -f1 | cut -d' ' -f2)
do
        id=$(aws --profile $account configure get accountid)
        role=$(aws --profile $account configure get role)

        [ -z $id ] && continue

        arn="arn:aws:iam::$id:role/$role"

        token="$(aws --profile $login_profile sts assume-role --role-arn $arn --role-session-name $account)"

        aws --profile $account configure set aws_access_key_id $(echo "$token" | grep AccessKeyId | cut -d'"' -f4)
        aws --profile $account configure set aws_secret_access_key $(echo "$token" | grep SecretAccessKey | cut -d'"' -f4)
        aws --profile $account configure set aws_session_token $(echo "$token" | grep SessionToken | cut -d'"' -f4)
done

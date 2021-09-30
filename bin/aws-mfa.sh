#!/bin/bash -e

AWS_ACCESS_KEY_ID=""
AWS_SECRET_ACCESS_KEY=""
AWS_SESSION_TOKEN=""

#find all login profiles that need to use MFA to login
for profile in $(grep '^\[profile' $HOME/.aws/config | cut -d']' -f1 | cut -d' ' -f2)
do
	static_profile="$(aws --profile $profile configure get static_profile)" || continue

	aws --profile $profile sts get-caller-identity &> /dev/null && echo "skipping $profile profile" && continue

	user=$(aws --profile $static_profile sts get-caller-identity | grep Arn | cut -d'/' -f2 | cut -d'"' -f1)

	serial=$(aws --profile $static_profile iam list-mfa-devices --user $user --query MFADevices[0].SerialNumber | cut -d'"' -f2)

	read -p "Enter MFA code for $serial ($profile profile) " code

	[ -z $code ] && continue

	token="$(aws --profile $static_profile sts get-session-token --serial-number $serial --token-code $code)"

	aws --profile $profile configure set aws_access_key_id $(echo "$token" | grep AccessKeyId | cut -d'"' -f4)
	aws --profile $profile configure set aws_secret_access_key $(echo "$token" | grep SecretAccessKey | cut -d'"' -f4)
	aws --profile $profile configure set aws_session_token $(echo "$token" | grep SessionToken | cut -d'"' -f4)

	echo "logged in to $profile profile"
done

#find all role profiles that can be switched to from a login profile
for profile in $(grep '^\[profile' $HOME/.aws/config | cut -d']' -f1 | cut -d' ' -f2)
do
	login_profile="$(aws --profile $profile configure get login_profile)" || continue
	id="$(aws --profile $profile configure get accountid)" || continue
	role="$(aws --profile $profile configure get role)" || continue

	! aws --profile $login_profile sts get-caller-identity &> /dev/null && echo "not logged in to $login_profile profile, skipping $profile profile" && continue

	arn="arn:aws:iam::$id:role/$role"

	token="$(aws --profile $login_profile sts assume-role --role-arn $arn --role-session-name $profile)"

	aws --profile $profile configure set aws_access_key_id $(echo "$token" | grep AccessKeyId | cut -d'"' -f4)
	aws --profile $profile configure set aws_secret_access_key $(echo "$token" | grep SecretAccessKey | cut -d'"' -f4)
	aws --profile $profile configure set aws_session_token $(echo "$token" | grep SessionToken | cut -d'"' -f4)

	echo "logged in to $profile profile"
done

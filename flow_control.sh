#!/bin/bash

# Written by Darinder S Shokar - ForgeRock Customer Success
# Script requires the "jq" tool be already installed to function

# Parameters. Modify as appropriate:
REALM=alpha
AM_HOST=https://openam-XXX/am
USERNAME=XXXX
PASSWORD=XXXX

# Static variables
AM_TREE=FlowControl
AM_AUTHENTICATE="$AM_HOST/json/realms/$REALM/authenticate?authIndexType=service&authIndexValue=$AM_TREE"
AM_VALIDATE="$AM_HOST/json/realms/root/realms/$REALM/sessions?_prettyPrint=true&_action=validate"
VERSION_HEADER='resource=2.0, protocol=1.0'
CONTENT_TYPE='application/json'

# On latent network connections there may be a need to retry, hence the following curl command is used.
CURL='curl -k -s --connect-timeout 1 --max-time 5 --retry 2'

jqCheck() {
	hash jq &>/dev/null
	if [ $? -eq 1 ]; then
		echo >&2 "The jq Command-line JSON processor is not installed on the system. Please install and re-run."
		exit 1
	fi
}

getCookieName() {
	echo "Getting cookie name"
	AM_COOKIENAME=$($CURL "$AM_HOST"/json/serverinfo/\* | jq -r .cookieName)
	echo "CookieName is: $AM_COOKIENAME"
}

authN() {
	echo "*********************"
	echo "Authenticating $USERNAME user to generate SSO token"
	AUTHN_RESPONSE=$($CURL --request POST --header "Content-Type: $CONTENT_TYPE" --header "Accept-API-Version: $VERSION_HEADER" --header "X-OpenAM-Username: $USERNAME" --header "X-OpenAM-Password: $PASSWORD" -d '' "$AM_AUTHENTICATE" | jq .)
	echo "AuthN Response is:"
	echo $AUTHN_RESPONSE | jq .
	SSO_TOKEN=$(echo $AUTHN_RESPONSE | jq -r .tokenId)
	echo ""
	echo "*********************"
}

#Functions
jqCheck
getCookieName
authN

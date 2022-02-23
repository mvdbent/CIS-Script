#!/bin/zsh

export PATH=/usr/bin:/bin:/usr/sbin:/sbin

####################################################################################################
####################################################################################################
# 
#        Written by:  Rob Potvin
#        Modified by: Armin Briegel
#
#        DESCRIPTION
#        This will upload CIS Benchmark Scoring CSV to the computer record
# 
#        REQUIREMENTS
#        Insert base64-encoded credentials within Parameter 4 in Jamf Pro
#
#        Created base64-encoded credentials:
#        printf "username:password" | /usr/bin/iconv -t ISO-8859-1 | /usr/bin/base64 -i -
# 
####################################################################################################
####################################################################################################

# Check to see if a value was passed in parameter 4 and, if so, assign to `basic_auth`
if [[ $basic_auth == "" ]]; then
    if [[ $4 != "" ]]; then
        basic_auth=$4
    else
        echo "basic_auth is unset, please insert base64-encoded credentials within Parameter 4 in Jamf Pro"
        exit 1
    fi
fi

# Variables
FILEPATH="/Library/Security/Reports/"
FILENAME="CISBenchmarkReport.csv"
FILE=${FILEPATH}${FILENAME}

# Check to see if CIS CSV is on computer
if [[ ! -f "$FILE" ]]; then
    echo "No $FILE"
    exit 1
fi

# Get JSS URL from prefrences
url=$(defaults read /Library/Preferences/com.jamfsoftware.jamf.plist jss_url)

# Get Serial Number of computer
serial=$(system_profiler SPHardwareDataType | awk '/Serial Number/ {print $NF}')

# these options will be added to all curl commands
curloptions=( --fail --retry 3 --retry-delay 1 --silent )

api_token=""

# MARK: Functions

# gets a value from json
function json_get {
    # $1: json text
    # $2: key or path in json
    osascript -l JavaScript -e "JSON.parse(\`$1\`).$2"
}

# gets a jamf api token
function jamfapi_gettoken {
    local json
    if ! json=$(curl $curloptions \
                           --request POST \
                           --header "Authorization: Basic ${basic_auth}" \
                           $url/api/v1/auth/token ); then
        echo "could not get api token"
        exit 3
    fi

    api_token=$(json_get $json "token")
    api_expiration=$(json_get $json "expires")
}

function jamfapi_invalidatetoken {
    if ! curl $curloptions \
            --request POST \
            --header "Authorization: Bearer $api_token" \
            $url/api/v1/auth/invalidate-token
    then
        echo "could not invalidate api token"
        exit 4
    fi

}

# function that encapsulates Jamf API calls
function jamfapi_request {
    # $1: request: GET, PUT, POST, or DELETE
    # $2: path, e.g. `computers/id/1`
    local request=${1:?"function jamfapi_request requires $1 (GET, PUT, POST, or DELETE)"}
    local api_path=${2:?"function jamfapi_request requires $2 (endpoint)"}
    local app_type="json"
    
    # capture remaining arguments
    shift 3
    local remaining_args=$@
    
    # get token, when necessary
    if [[ -z $api_token ]]; then
        jamfapi_gettoken
    fi
    
    curl $curloptions \
         --header "Authorization: Bearer $api_token" \
         --request $request \
         --header "accept: application/$app_type" \
         "$url/api/$api_path" \
         $@
}

function jamfapi_get {
    jamfapi_request GET $1 $@
}

function jamfapi_delete {
    jamfapi_request DELETE $1 $@
}

function jamfapi_post {
    jamfapi_request POST $1 $@
}

function json_list_attachments {
    # $1: json text
    # $2: path in json, e.g. `computers`
    # $3: name to match
    local json=${1?:"json_list_ids requires $1 (json)"}
    local jpath=${2?:"json_list_ids requires $2 (path)"}
    local name=${3?:"json_list_ids requires $3 (name)"}
    osascript -l JavaScript << EndOfScript
        const results = JSON.parse(\`$json\`).$jpath
        var output = ""
        for( const item of results ) {
            if ( item.name == "$name" ) {
                output += item.id + " "
            }
        }
        output
EndOfScript
}

function jamfapi_get_ids {
    # $1: path, e.g. `computers`
    local json=$(jamfapi_get_json $1)
    osascript -l JavaScript << EndOfScript
        const results = JSON.parse(\`$json\`).$1
        var output = ""
        for( const item of results ) {
            output += item.id + " "
        }
        output
EndOfScript
}

# MARK: main code starts here

# get token
if [[ -z $api_token ]]; then 
    jamfapi_gettoken
fi

# get computer inventory for serial
if ! computer_serial_json=$(jamfapi_get "v1/computers-inventory/?section=ATTACHMENTS&filter=hardware.serialNumber%3D%3D%22${serial}%22"); then
    echo "could not get data for computer with serial $serial"
    exit 2
fi

# get list of attachment ids that match file name
computer_id=$(json_get "$computer_serial_json" "results[0].id")
echo "computer id for serial $serial is $computer_id"
computer_attachment_ids=$(json_list_attachments "$computer_serial_json" "results[0].attachments" "$FILENAME")

# MARK: delete existing attachments
for attachment_id in ${(s. .)computer_attachment_ids} ; do
    echo "deleting attachment with id $attachment_id"
    if ! delete_result=$(jamfapi_delete "v1/computers-inventory/${computer_id}/attachments/${attachment_id}"); then
        echo "could not delete attachment with id $attachment_id"
        exit 3
    fi
done

# upload CIS Benchmark CSV
echo "attempting to upload $FILE"

if [[ ! -r "$FILE" ]]; then
    echo "$FILE does not exist."
    exit 1
fi 

if ! attachment_json=$(jamfapi_post "v1/computers-inventory/${computer_id}/attachments" \
                                    --form "file=@${FILE};type=text/csv")
then
    echo "could not upload attachment"
    exit 5
fi

attachment_id=$(json_get $attachment_json "id")
echo "uploaded attachment (new id is $attachment_id)"

# run jamf recon
if [[ $(whoami) == "root" ]]; then
    /usr/local/bin/jamf recon
fi

# invalidate token
jamfapi_invalidatetoken

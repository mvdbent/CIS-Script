#!/bin/zsh

export PATH=/usr/bin:/bin:/usr/sbin:/sbin

####################################################################################################
####################################################################################################
# 
#        Written by: Rob Potvin
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

# CHECK TO SEE IF A VALUE WAS PASSED IN PARAMETER 4 AND, IF SO, ASSIGN TO "password"

if [ "$4" != "" ] && [ "$basic_auth" == "" ]; then
	basic_auth=$4
else
	echo "basic_auth is unset, please insert base64-encoded credentials within Parameter 4 in Jamf Pro"
	exit 1
fi

# Variables
FILEPATH="/Library/Security/Reports/"
FILENAME="CISBenchmarkReport.csv"
FILE=${FILEPATH}${FILENAME}
timeStamp=$( date '+%Y-%m-%d-%H-%M-%S' )

# Check to see if CIS CSV is on computer, if so rename with the date for upload
if [ -f "$FILE" ]; then
	mv ${FILE} ${FILE%.csv}-uploaded-$timeStamp.csv
else 
	echo "No $FILE"
	exit 1
fi

# Get JSS URL from prefrences
jss=$(defaults read /Library/Preferences/com.jamfsoftware.jamf.plist jss_url)

# Get Serial Number of computer
serial=$(/usr/sbin/system_profiler SPHardwareDataType | awk '/Serial Number/ {print $NF}')

# find the machines ID
fullmachineinfo=$(curl -s "$jss"JSSResource/computers/serialnumber/"$serial" -H "Authorization: Basic ${basic_auth}")
machineid=$(echo $fullmachineinfo | /usr/bin/awk -F'<id>|</id>' '{print $2}'| sed 's/ /+/g')

# CSV has been renamed.. find the file to upload
RENAMEDCSV=$(ls /Library/Security/Reports/CISBenchmarkReport*)

# Upload Newest CIS Benchmark CSV
if [ -f "$RENAMEDCSV" ]; then
 	# Upload current CSV
    curl -s -X POST "$jss"JSSResource/fileuploads/computers/id/"$machineid" -F "name=@${RENAMEDCSV}" -H "Authorization: Basic ${basic_auth}"
    mv ${RENAMEDCSV} ${FILE}
    # Update CIS Benchmark Extension Attibutes
    jamf recon
else 
	echo "$FILE does not exist."
	exit 1
fi

exit 0
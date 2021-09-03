#!/bin/zsh

script_dir=$(dirname ${0:A})
projectfolder=$(dirname $script_dir)

source ${projectfolder}/Header.sh

CISLevel="2"
audit="2.6.1 iCloud configuration (Manual)"
orgScore="OrgScore2_6_1"
emptyVariables
# Verify organizational score
runAudit
# If organizational score is 1 or true, check status of client
if [[ "${auditResult}" == "1" ]]; then
	over500=$(dscl . list /Users UniqueID 2>&1 | /usr/bin/awk '$2 > 500 { print $1 }')
	for EachUser in $over500 ;
	do
		UserHomeDirectory=$(dscl . -read /Users/"$EachUser" NFSHomeDirectory 2>&1 | /usr/bin/awk '{print $2}')
		CheckForiCloudAccount=$(defaults read "$UserHomeDirectory/Library/Preferences/MobileMeAccounts" Accounts 2>&1 | /usr/bin/grep -c 'AccountDescription = iCloud')
		# If client fails, then note category in audit file
		if [[ "${CheckForiCloudAccount}" -gt "0" ]] ; then
			result="Failed"
			comment="${CheckForiCloudAccount} iCloud account(s) configured"
		else
			result="Passed"
			comment="no iCloud account(s) configured"
			fi
	done
fi
printReport
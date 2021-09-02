#!/bin/zsh

projectfolder=$(dirname "${0:A}")

source ${projectfolder}/Header.sh

CISLevel="1"
audit="2.5.1.3 Ensure all user storage CoreStorage volumes are encrypted (Manual)"
orgScore="OrgScore2_5_1_3"
emptyVariables
# Verify organizational score
runAudit
# If organizational score is 1 or true, check status of client
if [[ "${auditResult}" == "1" ]]; then
	apfsyes=$(diskutil ap list)
	if [[ "$apfsyes" == "No APFS Containers found" ]]; then
		# get Logical Volume Family
		LFV=$(diskutil cs list | grep "Logical Volume Family" | awk '/Logical Volume Family/ {print $5}')
		# Check encryption status is complete
		EncryptStatus=$(diskutil cs "$LFV" | awk '/Conversion Status/ {print $3}')
		if [[ "$EncryptStatus" != "Complete" ]]; then
			result="Failed"
			comment="Ensure all user CoreStorage volumes encrypted"
		else 
			result="Passed"
			comment="All user CoreStorage volumes encrypted"
		fi
	else 
		result="Not applicable"
		comment="Volumes: APFS"
	fi
fi
printReport
#!/bin/zsh
# shellcheck shell=bash

script_dir=$(dirname ${0:A})
projectfolder=$(dirname $script_dir)

source "${projectfolder}/Header.sh"

CISLevel="1"
audit="2.5.1.3 Ensure all user storage CoreStorage volumes are encrypted (Manual)"
orgScore="OrgScore2_5_1_3"
emptyVariables
# Verify organizational score
runAudit
# If organizational score is 1 or true, check status of client
if [[ "${auditResult}" == "1" ]]; then
	method="Manual"
	remediate="Manual > Ensure all user CoreStorage volumes encrypted"

	coreStorage=$(diskutil cs list)
	if [[ "$coreStorage" != "No CoreStorage logical volume groups found" ]]; then
		# get Logical Volume Family
		lvf=$(diskutil cs list | grep "Logical Volume Family" | awk '/Logical Volume Family/ {print $5}')
		# Check encryption status is complete
		EncryptStatus=$(diskutil cs "$lfv" | awk '/Conversion Status/ {print $3}')
		if [[ "$EncryptStatus" != "Complete" ]]; then
			result="Failed"
			comment="Ensure all user CoreStorage volumes encrypted"
		else 
			result="Passed"
			comment="All user CoreStorage volumes encrypted"
		fi
	else 
		result="Not Applicable"
		comment="No CoreStorage logical volume groups found"
	fi
fi
printReport
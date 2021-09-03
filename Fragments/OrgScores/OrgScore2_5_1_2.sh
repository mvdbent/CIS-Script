#!/bin/zsh

script_dir=$(dirname ${0:A})
projectfolder=$(dirname $script_dir)

source ${projectfolder}/Header.sh

CISLevel="1"
audit="2.5.1.2 Ensure all user storage APFS volumes are encrypted (Manual)"
orgScore="OrgScore2_5_1_2"
emptyVariables
# Verify organizational score
runAudit
# If organizational score is 1 or true, check status of client
if [[ "${auditResult}" == "1" ]]; then
	apfsyes=$(diskutil ap list)
	if [[ "$apfsyes" != "No APFS Containers found" ]]; then
		startupEncrypted=$(diskutil info / | awk '/FileVault/ {print $2}')
		if [[ "$startupEncrypted" == "Yes" ]]; then
			result="Passed"
			comment="Startup Volume: Encrypted"
		else
			result="Failed"
			comment="Ensure all user storage APFS Volumes are encrypted"
		fi 
	else 
		result="Not applicable"
		comment="Volumes: CoreStorage"
	fi
fi
printReport
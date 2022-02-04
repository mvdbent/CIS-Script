#!/bin/zsh

script_dir=$(dirname ${0:A})
projectfolder=$(dirname $script_dir)

source ${projectfolder}/Header.sh

CISLevel="1"
audit="5.1.2 Ensure System Integrity Protection Status (SIPS) Is Enabled (Automated)"
orgScore="OrgScore5_1_2"
emptyVariables
# Verify organizational score
runAudit
# If organizational score is 1 or true, check status of client
if [[ "${auditResult}" == "1" ]]; then
	method="Script"
	remediate="Manual - This tool needs to be executed from the Recovery OS '/usr/bin/csrutil enable'"

	sipStatus="$(csrutil status | grep -c "System Integrity Protection status: enabled")"
	if [[ "${sipStatus}" == "1" ]]; then
		result="Passed"
		comment="System Integrity Protection Status (SIPS): Enabled"
	else 
		result="Failed"
		comment="System Integrity Protection Status (SIPS): Disabled"
	fi
fi
printReport
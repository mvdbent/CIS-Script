#!/bin/zsh
# shellcheck shell=bash

script_dir=$(dirname ${0:A})
projectfolder=$(dirname $script_dir)

source "${projectfolder}/Header.sh"

CISLevel="2"
audit="2.5.4 Audit Location Services Access (Manual)"
orgScore="OrgScore2_5_4"
emptyVariables
# Verify organizational score
runAudit
# If organizational score is 1 or true, check status of client
if [[ "${auditResult}" == "1" ]]; then
	method="Manual"
	remediate="Manual > Disable unnecessary applications from accessing location services"
	
	locationServices=$(defaults read /var/db/locationd/clients.plist 2>&1 | grep -c "Authorized")
	if [[ "${locationServices}" != "0" ]]; then
		result="Notice"
		comment="${locationServices} applications can accessing location services"
	else 
		result="Passed"
		comment="No Location Services Access"
	fi
fi
printReport
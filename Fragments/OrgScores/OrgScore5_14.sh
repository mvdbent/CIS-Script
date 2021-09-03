#!/bin/zsh

script_dir=$(dirname ${0:A})
projectfolder=$(dirname $script_dir)

source ${projectfolder}/Header.sh

CISLevel="2"
audit="5.14 Create a Login window banner (Automated)"
orgScore="OrgScore5_14"
emptyVariables
# Verify organizational score
runAudit
# If organizational score is 1 or true, check status of client
if [[ "${auditResult}" == "1" ]]; then
	method="Script"
	remediate="https://support.apple.com/en-us/HT202277"

	policyBanner="$(find /Library/Security -name 'PolicyBanner.rtf*' | wc -l)"
	if [[ "${policyBanner}" == "1" ]]; then
		result="Passed"
		comment="Login window banner: Enabled"
	else 
		result="Failed"
		comment="Login window banner: Disabled"
	fi
fi
printReport
#!/bin/zsh

projectfolder=$(dirname "${0:A}")

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
		countPassed=$((countPassed + 1))
		result="Passed"
		comment="Login window banner: Enabled"
	else 
		countFailed=$((countFailed + 1))
		result="Failed"
		comment="Login window banner: Disabled"
	fi
fi
printReport
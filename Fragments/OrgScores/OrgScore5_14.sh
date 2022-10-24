#!/bin/zsh
# shellcheck shell=bash

script_dir=$(dirname ${0:A})
projectfolder=$(dirname $script_dir)

source "${projectfolder}/Header.sh"

CISLevel="1"
audit="5.14 Ensure Users Accounts Do Not Have a Password Hint (Automated)"
orgScore="OrgScore5_14"
emptyVariables
# Verify organizational score
runAudit
# If organizational score is 1 or true, check status of client
if [[ "${auditResult}" == "1" ]]; then
	method="Script"
	remediate="Script > sudo /usr/bin/dscl . -delete /Users/<username> hint"

	passwordHint="$(dscl . -list /Users hint | awk '{print $2}' | wc -l | xargs)"
	if [[ "${passwordHint}" == "0" ]]; then
		result="Passed"
		comment="Password Hint: Disabled"
	else 
		result="Failed"
		comment="Password Hint: Enabled"
		# Remediation
		if [[ "${remediateResult}" == "enabled" ]]; then
			for u in $(/usr/bin/dscl . -list /Users UniqueID | /usr/bin/awk '$2 > 500 {print $1}'); do
			/usr/bin/dscl . -delete /Users/$u hint
			done 
			# re-check
			passwordHint="$(dscl . -list /Users hint | awk '{print $2}' | wc -l | xargs)"
			if [[ "${passwordHint}" == "0" ]]; then
				result="Passed After Remediation"
				comment="Password Hint: Disabled"
			else
				result="Failed After Remediation"
			fi
		fi

		
	fi
fi
printReport
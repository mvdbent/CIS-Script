#!/bin/zsh

script_dir=$(dirname ${0:A})
projectfolder=$(dirname $script_dir)

source ${projectfolder}/Header.sh

CISLevel="2"
audit="5.2.6 Ensure Complex Password Must Contain Uppercase and Lowercase Characters Is Configured (Manual)"
orgScore="OrgScore5_2_6"
emptyVariables
# Verify organizational score
runAudit
# If organizational score is 1 or true, check status of client
if [[ "${auditResult}" == "1" ]]; then
	method="Script"
	remediate='Script > sudo /usr/bin/pwpolicy -n /Local/Default -setglobalpolicy "requiresMixedCase=1"'

	upperLowercase="$(pwpolicy getaccountpolicies | grep -v "Getting global account policies" | xmllint --xpath '/plist/dict/array/dict/dict[key="minimumMixedCaseCharacters"]/integer' - 2>&1 | awk -F '[<>]' '{print $3}')"
	if [[ "${upperLowercase}" == "1" ]]; then
		result="Passed"
		comment="Password Uppercase and Lowercase Characters: Configured"
	else 
		result="Failed"
		comment="Password Uppercase and Lowercase Characters: Disabled"
		# Remediation
		if [[ "${remediateResult}" == "enabled" ]]; then
			pwpolicy -n /Local/Default -setglobalpolicy "requiresMixedCase=1"
			# re-check
			upperLowercase="$(pwpolicy getaccountpolicies | grep -v "Getting global account policies" | xmllint --xpath '/plist/dict/array/dict/dict[key="minimumMixedCaseCharacters"]/integer' - | awk -F '[<>]' '{print $3}')"
			if [[ "${upperLowercase}" == "1" ]]; then
				result="Passed After Remediation"
				comment="Password Uppercase and Lowercase Characters: Enabled"
			else
				result="Failed After Remediation"
			fi
		fi
	fi
fi
printReport
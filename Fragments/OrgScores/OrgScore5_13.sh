#!/bin/zsh

script_dir=$(dirname ${0:A})
projectfolder=$(dirname $script_dir)

source ${projectfolder}/Header.sh

CISLevel="2"
audit="5.13 Ensure a Login Window Banner Exists (Automated)"
orgScore="OrgScore5_13"
emptyVariables
# Verify organizational score
runAudit
# If organizational score is 1 or true, check status of client
if [[ "${auditResult}" == "1" ]]; then
	method="Script"
	remediate="https://support.apple.com/en-us/HT202277"

	policyBanner="$(find /Library/Security -name 'PolicyBanner.*' | wc -l | xargs)"
	if [[ "${policyBanner}" == "1" ]]; then
		result="Passed"
		comment="Login window banner: Enabled"
	else 
		result="Failed"
		comment="Login window banner: Disabled"
		# Remediation
		if [[ "${remediateResult}" == "enabled" ]]; then
			PolicyBannerText="CIS Example Login Window banner"
			/bin/echo "$PolicyBannerText" > "/Library/Security/PolicyBanner.txt"
			/bin/chmod 755 "/Library/Security/PolicyBanner."* 
			# re-check
			policyBanner="$(find /Library/Security -name 'PolicyBanner.*' | wc -l | xargs)"
			if [[ "${policyBanner}" == "1" ]]; then
				result="Passed After Remediation"
				comment="Login window banner: Enabled"
			else
				result="Failed After Remediation"
			fi
		fi

		
	fi
fi
printReport
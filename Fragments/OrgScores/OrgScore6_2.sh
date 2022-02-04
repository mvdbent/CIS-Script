#!/bin/zsh

script_dir=$(dirname ${0:A})
projectfolder=$(dirname $script_dir)

source ${projectfolder}/Header.sh

CISLevel="1"
audit="6.2 Ensure Show All Filename Extensions Setting is Enabled (Automated)"
orgScore="OrgScore6_2"
emptyVariables
# Verify organizational score
runAudit
# If organizational score is 1 or true, check status of client
if [[ "${auditResult}" == "1" ]]; then
	method="Script"
	remediate="Script > sudo -u ${currentUser} defaults write /Users/${currentUser}/Library/Preferences/.GlobalPreferences AppleShowAllExtensions -bool true"

	showAllExtensions="$(sudo -u "$currentUser" defaults read .GlobalPreferences AppleShowAllExtensions 2>/dev/null)"
	if [[ "${showAllExtensions}" == "1" ]]; then
		result="Passed"
		comment="Show All Filename Extensions: Enabled"
	else 
		result="Failed"
		comment="Show All Filename Extensions: Disabled"
		# Remediation
		if [[ "${remediateResult}" == "enabled" ]]; then
			sudo -u "$currentUser" defaults write /Users/"$currentUser"/Library/Preferences/.GlobalPreferences AppleShowAllExtensions -bool true
			# re-check
			showAllExtensions="$(sudo -u "$currentUser" defaults read .GlobalPreferences AppleShowAllExtensions 2>/dev/null)"
			if [[ "${showAllExtensions}" == "1" ]]; then
				result="Passed After Remediation"
				comment="Show All Filename Extensions: Enabled"
			else
				result="Failed After Remediation"
			fi
		fi
	fi
fi
printReport
#!/bin/zsh

script_dir=$(dirname ${0:A})
projectfolder=$(dirname $script_dir)

source ${projectfolder}/Header.sh

CISLevel="1"
audit="5.1.2 Check System Wide Applications for appropriate permissions (Automated)"
orgScore="OrgScore5_1_2"
emptyVariables
# Verify organizational score
runAudit
# If organizational score is 1 or true, check status of client
if [[ "${auditResult}" == "1" ]]; then
	method="Script"
	remediate="Script > sudo chmod -R o-w /Applications/<applicationname>"

	appPermissions="$(find /Applications -iname "*\.app" -type d -perm -2 -ls 2>&1 | wc -l | xargs)"
	if [[ "${appPermissions}" == "0" ]]; then
		result="Passed"
		comment="All System Wide Applications have appropriate permissions"
	else 
		result="Failed"
		comment="Check permissions of ${appPermissions} system wide Applications"
		# Remediation
		if [[ "${remediateResult}" == "enabled" ]]; then
			IFS=$'\n'
			for apps in $( /usr/bin/find /Applications -iname "*\.app" -type d -perm -2 ); do
			/bin/chmod -R o-w "$apps"
			done
			unset IFS
			# re-check
			appPermissions="$(find /Applications -iname "*\.app" -type d -perm -2 -ls 2>&1 | wc -l | xargs)"
			if [[ "${appPermissions}" == "0" ]]; then
				result="Passed After Remediation"
				comment="All System Wide Applications have appropriate permissions"
			else
				result="Failed After Remediation"
			fi
		fi	
	fi
fi
printReport
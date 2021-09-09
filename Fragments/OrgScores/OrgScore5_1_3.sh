#!/bin/zsh

script_dir=$(dirname ${0:A})
projectfolder=$(dirname $script_dir)

source ${projectfolder}/Header.sh

CISLevel="1"
audit="5.1.3 Check System folder for world writable files (Automated)"
orgScore="OrgScore5_1_3"
emptyVariables
# Verify organizational score
runAudit
# If organizational score is 1 or true, check status of client
if [[ "${auditResult}" == "1" ]]; then
	method="Script"
	remediate="Script > sudo chmod -R o-w /Path/<baddirectory>"

	sysPermissions="$(find /System/Volumes/Data/System -type d -perm -2 -ls 2>&1 | grep -v "Public/Drop Box" | wc -l | xargs)"
	if [[ "${sysPermissions}" == "0" ]]; then
		result="Passed"
		comment="All System folder for world are not writable files"
	else 
		result="Failed"
		comment="Check ${sysPermissions} System folder for world writable files"
		# Remediation
		if [[ "${remediateResult}" == "enabled" ]]; then
			IFS=$'\n'
			for sysPermissions in $( /usr/bin/find /System/Volumes/Data/System -type d -perm -2 -ls | /usr/bin/grep -v "Public/Drop Box" ); do
			/bin/chmod -R o-w "$sysPermissions"
			done
			unset IFS
			# re-check
			sysPermissions="$(find /System/Volumes/Data/System -type d -perm -2 -ls 2>&1 | grep -v "Public/Drop Box" | wc -l | xargs)"
			if [[ "${sysPermissions}" == "0" ]]; then
				result="Passed After Remediation"
				comment="All System folder for world are not writable files"
			else
				result="Failed After Remediation"
			fi
		fi	
	fi
fi
printReport
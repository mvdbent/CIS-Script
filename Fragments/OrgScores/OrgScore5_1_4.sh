#!/bin/zsh

script_dir=$(dirname ${0:A})
projectfolder=$(dirname $script_dir)

source ${projectfolder}/Header.sh

CISLevel="2"
audit="5.1.4 Check Library folder for world writable files (Automated)"
orgScore="OrgScore5_1_4"
emptyVariables
# Verify organizational score
runAudit
# If organizational score is 1 or true, check status of client
if [[ "${auditResult}" == "1" ]]; then
	method="Script"
	remediate="Script > sudo chmod -R o-w /System/Volumes/Data/Library/<baddirectory>"

	libPermissions="$(find /Library -type d -perm -2 -ls 2>&1 | grep -v Caches | grep -v Adobe | grep -v VMware | grep -v "/Audio/Data" | wc -l | xargs)"
	if [[ "${libPermissions}" == "0" ]]; then
		result="Passed"
		comment="All Library folder for world are not writable files"
	else 
		result="Failed"
		comment="Check ${libPermissions} Library folders for world writable files"
		# Remediation
		if [[ "${remediateResult}" == "enabled" ]]; then
			IFS=$'\n'
			for libPermissions in $(find /Library -type d -perm -2 2>&1 | grep -v Caches | grep -v Adobe | grep -v VMware | grep -v "/Audio/Data"); do
			/bin/chmod -R o-w "$libPermissions"
			done
			unset IFS
			# re-check
			libPermissions="$(find /Library -type d -perm -2 -ls 2>&1 | grep -v Caches | grep -v Adobe | grep -v VMware | grep -v "/Audio/Data" | wc -l | xargs)"
			if [[ "${libPermissions}" == "0" ]]; then
				result="Passed After Remediation"
				comment="All Library folder for world are not writable files"
			else
				result="Failed After Remediation"
			fi
		fi
	fi
fi
printReport
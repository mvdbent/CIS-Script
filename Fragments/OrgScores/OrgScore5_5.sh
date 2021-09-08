#!/bin/zsh

script_dir=$(dirname ${0:A})
projectfolder=$(dirname $script_dir)

source ${projectfolder}/Header.sh

CISLevel="1"
audit="5.5 Use a separate timestamp for each user/tty combo (Automated)"
orgScore="OrgScore5_5"
emptyVariables
# Verify organizational score
runAudit
# If organizational score is 1 or true, check status of client
if [[ "${auditResult}" == "1" ]]; then
	method="Script"
	remediate="Script > sudo sed -i '.old' '/Default !tty_tickets/d' /etc/sudoers && sudo chmod 644 /etc/sudoers && sudo chown root:wheel /etc/sudoers"

	ttyTimestamp="$(grep -c tty_tickets /etc/sudoers)"
	if [[ "${ttyTimestamp}" == "1" ]]; then
		result="Passed"
		comment="Separate timestamp for each user/tty combo: Enabled"
	else 
		result="Failed"
		comment="Separate timestamp for each user/tty combo: Disabled"
		# Remediation
		if [[ "${remediateResult}" == "enabled" ]]; then
			echo "Defaults tty_tickets" >> /etc/sudoers
			# re-check
			ttyTimestamp="$(grep -c tty_tickets /etc/sudoers)"
			if [[ "${ttyTimestamp}" == "1" ]]; then
				result="Passed After Remediation"
				comment="Separate timestamp for each user/tty combo: Enabled"
			else
				result="Failed After Remediation"
			fi
		fi
	fi
fi
printReport
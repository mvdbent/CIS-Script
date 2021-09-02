#!/bin/zsh

projectfolder=$(dirname "${0:A}")

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
	if [[ "${ttyTimestamp}" == "0" ]]; then
		result="Passed"
		comment="Separate timestamp for each user/tty combo: Enabled"
	else 
		result="Failed"
		comment="Separate timestamp for each user/tty combo: Disabled"
	fi
fi
printReport
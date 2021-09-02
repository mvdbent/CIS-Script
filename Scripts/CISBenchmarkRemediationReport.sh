#!/bin/zsh
#!/bin/zsh

####################################################################################################
#        License information
####################################################################################################
#
#        THE SCRIPTS ARE PROVIDED "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, 
#        INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY 
#        AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL 
#        I BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, 
#        OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF 
#        SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS 
#        INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN 
#        CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) 
#        ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF 
#        THE POSSIBILITY OF SUCH DAMAGE.
#
####################################################################################################
# 
# Version 0.9
# Written by: Mischa van der Bent
#
# DESCRIPTION
# This script is inspired by the CIS Benchmark script of Jamf here https://github.com/jamf/CIS-for-macOS-Catalina-CP
# The script will look for a managed Configuration Profile (com.cis.benchmark.plist) and does the check, remediation (if needend) and report.
# The Security Score can be set with a managed Configuration Profile (com.cis.benchmark.plist)
# Reports are stored in this location /Library/Security/Reports.
# 
# REQUIREMENTS
# Compatible with Big Sure macOS 11.x
# Compatible with Monterey macOS 12.x 
# 
####################################################################################################
####################################################################################################

export PATH=/usr/bin:/bin:/usr/sbin:/sbin

### Directory/Path/Variables
CISBenchmarkReportPath="/Library/Security/Reports"
CISBenchmarkReport=${CISBenchmarkReportPath}/CISBenchmarkReport.csv
CISBenchmarkReportEA=${CISBenchmarkReportPath}/CISBenchmarkReportEA.txt
plistlocation="/Library/Managed Preferences/com.cis.benchmark.plist"
currentUser=$(scutil <<< "show State:/Users/ConsoleUser" | awk '/Name :/ { print $3 }')

### Functions
function runAudit () {
	## Check if scoring file is present
	if [[ ! -e ${plistlocation} ]]; then
		## No scoring file present, reporting all
		auditResult="1"
		scored=""
		echo "OrgScore ${audit}"
	else
		auditResult=$(defaults read "${plistlocation}" "${orgScore}" 2>&1)
		if [[ "${auditResult}" == "1" ]]; then
			scored="Scored"
			echo "OrgScore ${audit}"
		else
			scored="NOT Scored"
		fi
	fi
}

function runAsUser() {
	if [[ "${currentUser}" != "loginwindow" ]]; then
		uid=$(id -u "${currentUser}")
		launchctl asuser "$uid" sudo -u "${currentUser}" "$@"
	fi
}

function getPrefValue { # $1: domain, $2: key
	python -c "from Foundation import CFPreferencesCopyAppValue; print(CFPreferencesCopyAppValue('$2', '$1'))"
}

function getPrefValueNested { # $1: domain, $2: key
	python -c "from Foundation import CFPreferencesCopyAppValue; print(CFPreferencesCopyAppValue('$2', '$1'))['$3']"
}

function getPrefValuerunAsUser { # $1: domain, $2: key
	runAsUser python -c "from Foundation import CFPreferencesCopyAppValue; print(CFPreferencesCopyAppValue('$2', '$1'))"
}

function getPrefIsManaged { # $1: domain, $2: key
	python -c "from Foundation import CFPreferencesAppValueIsForced; print(CFPreferencesAppValueIsForced('$2', '$1'))"
}

function getPrefIsManagedrunAsUser { # $1: domain, $2: key
	runAsUser python -c "from Foundation import CFPreferencesAppValueIsForced; print(CFPreferencesAppValueIsForced('$2', '$1'))"
}

### Functions
function CISBenchmarkReportFolder () {
	if [[ -d ${CISBenchmarkReportPath} ]]; then
		rm -Rf "${CISBenchmarkReportPath}"
		mkdir -p "${CISBenchmarkReportPath}"
		else
		mkdir -p "${CISBenchmarkReportPath}"
	fi
}

function printReport(){
	echo "${audit};${CISLevel};${scored};${result};${prefIsManaged};${appidentifier};${value};${prefValue};${method};${comment};${remediate}">>"${CISBenchmarkReport}"
}

function emptyVariables(){
	prefIsManaged=""
	appidentifier=""
	value=""
	prefValue=""
	result=""
	method=""
	comment=""
	remediate=""
}

# Start Security report script
echo ""
echo "*** Security report started - $(date -u)"

# Check for admin/root permissions
if [[ "$(id -u)" != "0" ]]; then
	echo ""
	echo "*** Script must be run as root, or have root privileges (ie. sudo)." 1>&2
	echo "*** Quitting..."
	echo ""
	exit 1
fi

# Check for Big sur
osVersion=$(sw_vers -productVersion)
buildVersion=$(sw_vers -buildVersion)
if [[ "$osVersion" != "11."* ]] && [[ "$osVersion" != "12."* ]]; then
		echo ""
		echo "*** This script support macOS Big Sur and Monterey only"
		echo "*** Quitting..."
		echo ""
		exit 1
	else
		if [[ "$osVersion" = "11."* ]]; then
			echo "*** Current version - macOS Big Sur ${osVersion} (${buildVersion})"
			echo "" 1>&2
		else
			echo "*** Current version - macOS Monterey ${osVersion} (${buildVersion})"
			echo "" 1>&2
		fi
	fi

# Create report Folder/Files
CISBenchmarkReportFolder

# Create csv file headers
echo "Audit Number;Level;Scored;Result;Managed;Preference domain;Option;Value;Method;Comments;Remediate" >> "${CISBenchmarkReport}"

#####################################################################################################################################
#####################################################################################################################################
#################################################### DO NOT EDIT BELOW THIS LINE ####################################################
#####################################################################################################################################
#####################################################################################################################################

CISLevel="1"
audit="1.1 Verify all Apple-provided software is current (Automated)"
orgScore="OrgScore1_1"
emptyVariables
method="Script"
remediate="Script > sudo /usr/sbin/softwareupdate --install --restart --recommended"
# Verify organizational score
runAudit
# If organizational score is 1 or true, check status of client
if [[ "${auditResult}" == "1" ]]; then
	countAvailableSUS=$(softwareupdate -l 2>&1 | grep -c "*")
	if [[ "${countAvailableSUS}" == "0" ]]; then
		result="Passed"
		comment="Apple Software is Current"
	else
		result="Failed"
		comment="Available Updates: ${countAvailableSUS}, verify all Apple provided software is current"
	fi
fi
printReport

CISLevel="1"
audit="1.2 Enable Auto Update (Automated)"
orgScore="OrgScore1_2"
emptyVariables
# Verify organizational score
runAudit
# If organizational score is 1 or true, check status of client
if [[ "${auditResult}" == "1" ]]; then
	method="Profile"
	remediate="Configuration profile - payload > com.apple.SoftwareUpdate > AutomaticCheckEnabled=true"
	
	appidentifier="com.apple.SoftwareUpdate"
	value="AutomaticCheckEnabled"
	prefValue=$(getPrefValue "${appidentifier}" "${value}")
	prefIsManaged=$(getPrefIsManaged "${appidentifier}" "${value}")
	comment="Auto Update: Enabled"
	if [[ "${prefIsManaged}" == "True" && "${prefValue}" == "True" ]]; then
		result="Passed"
	else
		if [[ "${prefValue}" == "True" ]]; then
			result="Passed"
		else
			result="Failed"
			comment="Auto Update: Disabled"
			
		fi
	fi
fi
printReport

CISLevel="1"
audit="1.3 Enable Download new updates when available (Automated)"
orgScore="OrgScore1_3"
emptyVariables
# Verify organizational score
runAudit
# If organizational score is 1 or true, check status of client
if [[ "${auditResult}" == "1" ]]; then
	method="Profile"
	remediate="Configuration profile - payload > com.apple.SoftwareUpdate > AutomaticDownload=true"

	appidentifier="com.apple.SoftwareUpdate"
	value="AutomaticDownload"
	prefValue=$(getPrefValue "${appidentifier}" "${value}")
	prefIsManaged=$(getPrefIsManaged "${appidentifier}" "${value}")
	comment="Download new updates when available: Enabled"
	if [[ "${prefIsManaged}" == "True" && "${prefValue}" == "True" ]]; then
		result="Passed"
	else
		if [[ "${prefValue}" == "True" ]]; then
			result="Passed"
		else
			result="Failed"
			comment="Download new updates when available: Disabled"
		fi
	fi
fi
printReport

CISLevel="1"
audit="1.4 Enable app update installs (Automated)"
orgScore="OrgScore1_4"
emptyVariables
# Verify organizational score
runAudit
# If organizational score is 1 or true, check status of client
if [[ "${auditResult}" == "1" ]]; then
	method="Profile"
	remediate="Configuration profile - payload > com.apple.SoftwareUpdate > AutomaticallyInstallAppUpdates=true"

	appidentifier="com.apple.commerce"
	value="AutoUpdate"
	prefValue=$(getPrefValue "${appidentifier}" "${value}")
	prefIsManaged=$(getPrefIsManaged "${appidentifier}" "${value}")
	comment="App updates: Enabled"
	if [[ "${prefIsManaged}" == "True" && "${prefValue}" == "True" ]]; then
		result="Passed"
	else
		if [[ "${prefValue}" == "True" ]]; then
			result="Passed"
		else
			result="Failed"
			comment="App updates: Disabled"
		fi
	fi
fi
printReport

CISLevel="1"
audit="1.5 Enable system data files and security updates install (Automated)"
orgScore="OrgScore1_5"
emptyVariables
# Verify organizational score
runAudit
# If organizational score is 1 or true, check status of client
if [[ "${auditResult}" == "1" ]]; then
	method="Profile"
	remediate="Configuration profile - payload > com.apple.SoftwareUpdate > ConfigDataInstall=true - CriticalUpdateInstall=true "

	appidentifier="com.apple.SoftwareUpdate"
	value="ConfigDataInstall"
	value2="CriticalUpdateInstall"
	prefValue=$(getPrefValue "${appidentifier}" "${value}")
	prefValue2=$(getPrefValue "${appidentifier}" "${value2}")
	prefIsManaged=$(getPrefIsManaged "${appidentifier}" "${value}")
	comment="System data files and security update installs: Enabled"
	if [[ "${prefIsManaged}" == "True" && "${prefValue}" == "True" && "${prefValue2}" == "True" ]]; then
		result="Passed"
	else
		if [[ "${prefValue}" == "True" && "${prefValue2}" == "True" ]]; then
			result="Passed"
		else
			result="Failed"
			comment="System data files and security update installs: Disabled"
		fi
	fi
fi
printReport

CISLevel="1"
audit="1.6 Enable macOS update installs (Automated)"
orgScore="OrgScore1_6"
emptyVariables
# Verify organizational score
runAudit
# If organizational score is 1 or true, check status of client
if [[ "${auditResult}" == "1" ]]; then
	method="Profile"
	remediate="Configuration profile - payload > com.apple.SoftwareUpdate > AutomaticallyInstallMacOSUpdates=true)"

	appidentifier="com.apple.SoftwareUpdate"
	value="AutomaticallyInstallMacOSUpdates"
	prefValue=$(getPrefValue "${appidentifier}" "${value}")
	prefIsManaged=$(getPrefIsManaged "${appidentifier}" "${value}")
	comment="macOS update installs: Enabled"
	if [[ "${prefIsManaged}" == "True" && "${prefValue}" == "True" ]]; then
		result="Passed"
	else
		if [[ "${prefValue}" == "True" ]]; then
			result="Passed"
		else
			result="Failed"
			comment="macOS update installs: Disabled"
		fi
	fi
fi
printReport

CISLevel="1"
audit="2.10 Enable Secure Keyboard Entry in terminal.app (Automated)"
orgScore="OrgScore2_10"
emptyVariables
# Verify organizational score
runAudit
# If organizational score is 1 or true, check status of client
if [[ "${auditResult}" == "1" ]]; then
	method="Profile"
	remediate="Configuration profile - payload > com.apple.Terminal > SecureKeyboardEntry=true"

	appidentifier="com.apple.Terminal"
	value="SecureKeyboardEntry"
	prefValue=$(getPrefValue "${appidentifier}" "${value}")
	prefIsManaged=$(getPrefIsManaged "${appidentifier}" "${value}")
	comment="Secure Keyboard Entry in terminal.app: Enabled"
	if [[ "${prefIsManaged}" == "True" && "${prefValue}" == "True" ]]; then
		countPassed=$((countPassed + 1))
		result="Passed"
	else
		if [[ "${prefValue}" == "True" ]]; then
			countPassed=$((countPassed + 1))
			result="Passed"
		else
			countFailed=$((countFailed + 1))
			result="Failed"
			comment="Secure Keyboard Entry in terminal.app: Disabled"
		fi
	fi
fi
printReport

CISLevel="1"
audit="2.11 Ensure EFI version is valid and being regularly checked (Automated)"
orgScore="OrgScore2_11"
emptyVariables
# Verify organizational score
runAudit
# If organizational score is 1 or true, check status of client
if [[ "${auditResult}" == "1" ]]; then
	# Check for T2 chip.  
	securityChip=$(system_profiler SPiBridgeDataType 2>&1 | grep 'Model Name:' | grep -c 'T2')
	if [[ "${securityChip}" == "0" ]]; then
		countNotice=$((countNotice + 1))
		result="Not applicable"
		comment="EFI Firmware Integrity is not supported by this Mac. T2 Chip found."
	else
		method="Manual"
		remediate="If EFI does not pass the integrity check you may send a report to Apple. Backing up files and clean installing a known good Operating System and Firmware is recommended."
		efiStatus=$(/usr/libexec/firmwarecheckers/eficheck/eficheck --integrity-check | grep -c "No changes detected")
		if [[ "${efiStatus}" -gt 0 ]]; then
			countPassed=$((countPassed + 1))
			result="Passed"
			comment="EFI version: Valid"
		else
			countFailed=$((countFailed + 1))
			result="Failed"
			comment="EFI version: Invalid"
		fi
	fi
fi
printReport

CISLevel="1"
audit="2.1.1 Turn off Bluetooth, if no paired devices exist (Automated)"
orgScore="OrgScore2_1_1"
emptyVariables
# Verify organizational score
runAudit
# If organizational score is 1 or true, check status of client
if [[ "${auditResult}" == "1" ]]; then
	method="Profile"
	remediate="Configuration profile - payload > com.apple.MCXBluetooth > DisableBluetooth=true"

	appidentifier="com.apple.Bluetooth"
	value="ControllerPowerState"
	prefValue=$(getPrefValue "${appidentifier}" "${value}")
	prefIsManaged=$(getPrefIsManaged "${appidentifier}" "${value}")
	connectable=$(system_profiler SPBluetoothDataType 2>&1 | grep -c Connectable)
	comment="Paired Devices: ${connectable}"
	if [[ "${prefIsManaged}" == "True" &&  "${prefValue}" == "True" ]]; then
		result="Passed"
	else
		if [[ "${prefValue}" == "True" ]]; then
			result="Passed"
		else
			if [[ "${connectable}" != "0" ]]; then
				result="Passed"
			else
			result="Failed"
			comment="No Paired Devices"
			fi
		fi
	fi
fi
printReport

CISLevel="1"
audit="2.1.2 Show Bluetooth status in menu bar (Automated)"
orgScore="OrgScore2_1_2"
emptyVariables
# Verify organizational score
runAudit
# If organizational score is 1 or true, check status of client
if [[ "${auditResult}" == "1" ]]; then
	method="Script"
	remediate="Script > sudo -u firstuser defaults -currentHost write com.apple.controlcenter.plist Bluetooth -int 18"

	appidentifier="com.apple.controlcenter"
	value="NSStatusItem Visible Bluetooth"
	# function check2_1_2 {
	prefValueAsUser=$(getPrefValuerunAsUser "${appidentifier}" "${value}")
	prefIsManaged=$(getPrefIsManaged "${appidentifier}" "${value}")

	comment="Show Bluetooth status in menu bar: Enabled"
	if [[ "${prefIsManaged}" == "True" && "${prefValueAsUser}" == "True" ]]; then
		countPassed=$((countPassed + 1))
		result="Passed"
	else
		if [[ "${prefValueAsUser}" == "True" ]]
		then
			result="Passed"
		else
			result="Failed"
			comment="Enable Show Bluetooth status in menu bar"
			# Remediation
			su -l ${currentUser} -c "defaults -currentHost write com.apple.controlcenter.plist Bluetooth -int 18"
			killall ControlCenter
			sleep 3
			# re-check
			prefValueAsUser=$(getPrefValuerunAsUser "${appidentifier}" "${value}")
			prefIsManaged=$(getPrefIsManaged "${appidentifier}" "${value}")
			if [[ "${prefValueAsUser}" == "True" ]]; then
				result="Passed After Remdiation"
				comment="Show Bluetooth status in menu bar: Enabled"
			else
				result="Failed After Remediation"
			fi
		fi
	fi
fi
printReport

CISLevel="1"
audit='2.2.1 Enable "Set time and date automatically" (Automated)'
orgScore="OrgScore2_2_1"
emptyVariables
# Verify organizational score
runAudit
# If organizational score is 1 or true, check status of client
if [[ "${auditResult}" == "1" ]]; then
	method="Profile"
	remediate="Configuration profile - payload > com.apple.timed > TMAutomaticTimeOnlyEnabled=true"

	appidentifier="com.apple.timed"
	value="TMAutomaticTimeOnlyEnabled"
	prefValue=$(getPrefValue "${appidentifier}" "${value}")
	prefIsManaged=$(getPrefIsManaged "${appidentifier}" "${value}")
	comment="Time and date automatically: Enabled"
	if [[ "${prefIsManaged}" == "True" && "${prefValue}" == "1" ]]; then
		result="Passed"
	else
		if [[ "${prefValue}" == "1" ]]; then
			result="Passed"
		else
			networkTime=$(systemsetup -getusingnetworktime)
			if [[ "${networkTime}" = "Network Time: On" ]]; then
				result="Passed"
			else
				result="Failed"
				comment="Time and date automatically: Disabled"
			fi
		fi
	fi
fi
printReport

CISLevel="1"
audit="2.2.2 Ensure time set is within appropriate limits (Automated)"
orgScore="OrgScore2_2_2"
emptyVariables
# Verify organizational score
runAudit
# If organizational score is 1 or true, check status of client
if [[ "${auditResult}" == "1" ]]; then
	method="Script"
	remediate="Script > sudo /usr/sbin/systemsetup -setusingnetworktime on && sudo /usr/sbin/systemsetup -setnetworktimeserver time.euro.apple.com"

	networkTimeserver=$(systemsetup -getnetworktimeserver 2>&1 | grep -c 'Network Time Server')
	printCLIResult=$(systemsetup -getnetworktimeserver)
	if [[ "$networkTimeserver" != "0" ]]; then
		result="Passed"
		comment="${printCLIResult}"
	else
		result="Failed"
		comment="Set Network Time Server"
		# Remediation
		/usr/sbin/systemsetup -setusingnetworktime on && sudo /usr/sbin/systemsetup -setnetworktimeserver time.euro.apple.com
		# re-check
		networkTimeserver=$(systemsetup -getnetworktimeserver 2>&1 | grep -c 'Network Time Server')
		printCLIResult=$(systemsetup -getnetworktimeserver)
		if [[ "$networkTimeserver" != "0" ]]; then
			result="Passed After Remdiation"
			comment="${printCLIResult}"
		else
			result="Failed After Remediation"
		fi
	fi
fi
printReport

CISLevel="1"
audit="2.3.1 Set an inactivity interval of 20 minutes or less for the screen saver (Automated)"
orgScore="OrgScore2_3_1"
emptyVariables
# Verify organizational score
runAudit
# If organizational score is 1 or true, check status of client
if [[ "${auditResult}" == "1" ]]; then
	method="Profile"
	remediate="Configuration profile - payload > com.apple.screensaver > idleTime=1200"

	appidentifier="com.apple.screensaver"
	value="idleTime"
	prefValueAsUser=$(getPrefValuerunAsUser "${appidentifier}" "${value}")
	prefIsManaged=$(getPrefIsManaged "${appidentifier}" "${value}")
	comment="Inactivity interval for the screen saver: ${prefValueAsUser}"
	if [[ "${prefIsManaged}" == "True" && "${prefValueAsUser}" -le "1200" ]]; then
		result="Passed"
	else
		if [[ "${prefValueAsUser}" -le "1200" && "${prefValueAsUser}" != "" ]]; then
			result="Passed"
		else
			result="Failed"
			comment="Inactivity interval for the screen saver: ${prefValueAsUser}"
		fi
	fi
fi
printReport

CISLevel="2"
audit="2.3.2 Secure screen saver corners (Automated)"
orgScore="OrgScore2_3_2"
emptyVariables
# Verify organizational score
runAudit
# If organizational score is 1 or true, check status of client
if [[ "${auditResult}" == "1" ]]; then
	method="Profile"
	remediate="Configuration profile - payload > com.apple.dock > wvous-tl-corner=5, wvous-br-corner=10, wvous-bl-corner=13, wvous-tr-corner=0 - 5=Start Screen Saver, 10=Put Display to Sleep, 13=Lock Screen"

	appidentifier="com.apple.dock"
	value="wvous-bl-corner"
	value2="wvous-tl-corner"
	value3="wvous-tr-corner"
	value4="wvous-br-corner"
	prefValueAsUser=$(getPrefValuerunAsUser "${appidentifier}" "${value}")
	prefValue2AsUser=$(getPrefValuerunAsUser "${appidentifier}" "${value2}")
	prefValue3AsUser=$(getPrefValuerunAsUser "${appidentifier}" "${value3}")
	prefValue4AsUser=$(getPrefValuerunAsUser "${appidentifier}" "${value4}")
	prefIsManaged=$(getPrefIsManagedrunAsUser "${appidentifier}" "${value}")
	prefIsManaged2=$(getPrefIsManagedrunAsUser "${appidentifier}" "${value2}")
	prefIsManaged3=$(getPrefIsManagedrunAsUser "${appidentifier}" "${value3}")
	prefIsManaged4=$(getPrefIsManagedrunAsUser "${appidentifier}" "${value4}")
	comment="Secure screen saver corners: enabled"
	if [[ "${prefIsManaged}" == "True" ]] || [[ "${prefIsManaged2}" == "True" ]] || [[ "${prefIsManaged3}" == "True" ]] || [[ "${prefIsManaged4}" == "True" ]]; then
		result="Passed"
	else
		if [[ "${prefValueAsUser}" == "5" ]] || [[ "${prefValue2AsUser}" == "5" ]] || [[ "${prefValue3AsUser}" == "5" ]] || [[ "${prefValue4AsUser}" == "5" ]]; then
			result="Passed"
		elif
			[[ "${prefValueAsUser}" == "10" ]] || [[ "${prefValue2AsUser}" == "10" ]] || [[ "${prefValue3AsUser}" == "10" ]] || [[ "${prefValue4AsUser}" == "10" ]]; then
				result="Passed"
			elif
				[[ "${prefValueAsUser}" == "13" ]] || [[ "${prefValue2AsUser}" == "13" ]] || [[ "${prefValue3AsUser}" == "13" ]] || [[ "${prefValue4AsUser}" == "13" ]]; then
					result="Passed"
				else
					result="Failed"
					comment="Secure screen saver corners: Disabled"
				fi
	fi
fi
value="${value}, ${value2}, ${value3}, ${value4}"
prefValue="${prefValueAsUser}, ${prefValue2AsUser}, ${prefValue3AsUser}, ${prefValue4AsUser}"
printReport

CISLevel="1"
audit="2.3.3 Familiarize users with screen lock tools or corner to Start Screen Saver (Manual)"
orgScore="OrgScore2_3_3"
emptyVariables
# Verify organizational score
runAudit
# If organizational score is 1 or true, check status of client
if [[ "${auditResult}" == "1" ]]; then
	method="Manual"
	remediate="Familiarise users with screen lock tools or corner to Start Screen Saver"
	
	appidentifier="com.apple.dock"
	value="wvous-bl-corner"
	value2="wvous-tl-corner"
	value3="wvous-tr-corner"
	value4="wvous-br-corner"
	prefValueAsUser=$(getPrefValuerunAsUser "${appidentifier}" "${value}")
	prefValue2AsUser=$(getPrefValuerunAsUser "${appidentifier}" "${value2}")
	prefValue3AsUser=$(getPrefValuerunAsUser "${appidentifier}" "${value3}")
	prefValue4AsUser=$(getPrefValuerunAsUser "${appidentifier}" "${value4}")
	prefIsManaged=$(getPrefIsManaged "${appidentifier}" "${value}")
	comment="End-users are familiar with screen lock tools or Hot Corners"
	if [[ "${prefIsManaged}" == "True" ]]; then
		result="Passed"
	else
		if [[ "${prefValueAsUser}" != "1" ]] || [[ "${prefValue2AsUser}" != "1" ]] || [[ "${prefValue3AsUser}" != "1" ]] || [[ "${prefValue4AsUser}" != "1" ]]; then
			result="Passed"
		else
			result="Failed"
			comment="Familiarise users with screen lock tools or corner to Start Screen Saver"
		fi
	fi
fi
value=""
prefValue=""
printReport

CISLevel="1"
audit="2.4.1 Disable Remote Apple Events (Automated)"
orgScore="OrgScore2_4_1"
emptyVariables
# Verify organizational score
runAudit
# If organizational score is 1 or true, check status of client
if [[ "${auditResult}" == "1" ]]; then
	method="Script"
	remediate="Script > sudo /usr/sbin/systemsetup -setremoteappleevents off && sudo launchctl disable system/com.apple.AEServer"

	remoteAppleEvents=$(systemsetup -getremoteappleevents)
	if [[ "$remoteAppleEvents" == "Remote Apple Events: Off" ]]; then
		result="Passed"
		comment="Remote Apple Events: Disabled"
	else
		result="Failed"
		comment="Remote Apple Events: Enabled"
	fi
fi
printReport

CISLevel="2"
audit="2.4.10 Disable Content Caching (Automated)"
orgScore="OrgScore2_4_10"
emptyVariables
# Verify organizational score
runAudit
# If organizational score is 1 or true, check status of client
if [[ "${auditResult}" == "1" ]]; then
	method="Profile"
	remediate="Configuration profile - payload > com.apple.applicationaccess > allowContentCaching=false"

	appidentifier="com.apple.applicationaccess"
	value="allowContentCaching"
	prefValue=$(getPrefValue "${appidentifier}" "${value}")
	prefIsManaged=$(getPrefIsManaged "${appidentifier}" "${value}")
	comment="Content Caching: Disabled"
	if [[ "${prefIsManaged}" == "True" && "${prefValue}" == "False" ]]; then
		countPassed=$((countPassed + 1))
		result="Passed"
	else
		if [[ "${prefValue}" == "False" ]]; then
			countPassed=$((countPassed + 1))
			result="Passed"
		else
			contentCacheStatus=$(AssetCacheManagerUtil status 2>&1 | grep -c "Activated: true")
			if [[ "${contentCacheStatus}" == 0 ]]; then
				countPassed=$((countPassed + 1))
				result="Passed"
			else
				countFailed=$((countFailed + 1))
				result="Failed"
				comment="Content Caching: Enabled"
			fi
		fi
	fi
fi
printReport

CISLevel="1"
audit="2.4.11 Disable Media Sharing (Automated)"
orgScore="OrgScore2_4_11"
emptyVariables
# Verify organizational score
runAudit
# If organizational score is 1 or true, check status of client
if [[ "${auditResult}" == "1" ]]; then
	method="Profile"
	remediate="Configuration profile - payload > com.apple.preferences.sharing.SharingPrefsExtension > homeSharingUIStatus=0 > legacySharingUIStatus=0 > mediaSharingUIStatus=0"

	appidentifier="com.apple.preferences.sharing.SharingPrefsExtension"
	value="homeSharingUIStatus"
	value2="legacySharingUIStatus"
	value3="mediaSharingUIStatus"
	prefValueAsUser=$(getPrefValuerunAsUser "${appidentifier}" "${value}")
	prefValue2AsUser=$(getPrefValuerunAsUser "${appidentifier}" "${value2}")
	prefValue3AsUser=$(getPrefValuerunAsUser "${appidentifier}" "${value3}")
	prefIsManaged=$(getPrefIsManaged "${appidentifier}" "${value}")
	comment="Media Sharing: Disabled"
	if [[ "${prefIsManaged}" == "True" && "${prefValueAsUser}" == "0" ]] && [[ "${prefValue2AsUser}" == "0" ]] && [[ "${prefValue3AsUser}" == "0" ]]; then
		countPassed=$((countPassed + 1))
		result="Passed"
	else 
		if [[ "${prefValueAsUser}" == "0" ]] && [[ "${prefValue2AsUser}" == "0" ]] && [[ "${prefValue3AsUser}" == "0" ]]; then
			countPassed=$((countPassed + 1))
			result="Passed"
		elif
			[[ "${prefValueAsUser}" == "" ]] && [[ "${prefValue2AsUser}" == "" ]] && [[ "${prefValue3AsUser}" == "" ]]; then
				countPassed=$((countPassed + 1))
				result="Passed"
			else
				countFailed=$((countFailed + 1))
				result="Failed"
				comment="Media Sharing: Enabled"
			fi
	fi
fi
value="${value}, ${value2}, ${value3}"
prefValue="${prefValueAsUser}, ${prefValue2AsUser}, ${prefValue3AsUser}"
printReport

CISLevel="1"
audit="2.4.2 Disable Internet Sharing (Automated)"
orgScore="OrgScore2_4_2"
emptyVariables
# Verify organizational score
runAudit
# If organizational score is 1 or true, check status of client
if [[ "${auditResult}" == "1" ]]; then
	method="Profile"
	remediate="Configuration profile - payload > com.apple.MCX > forceInternetSharingOff=true"

	comment="Internet Sharing: Disabled"
	if [[ -e /Library/Preferences/SystemConfiguration/com.apple.nat.plist ]]; then
		natAirport=$(/usr/libexec/PlistBuddy -c "print :NAT:AirPort:Enabled" /Library/Preferences/SystemConfiguration/com.apple.nat.plist > /dev/null 2>&1)
		natEnabled=$(/usr/libexec/PlistBuddy -c "print :NAT:Enabled" /Library/Preferences/SystemConfiguration/com.apple.nat.plist > /dev/null 2>&1)
		natPrimary=$(/usr/libexec/PlistBuddy -c "print :NAT:PrimaryInterface:Enabled" /Library/Preferences/SystemConfiguration/com.apple.nat.plist > /dev/null 2>&1)
		forwarding=$(sysctl net.inet.ip.forwarding 2>&1| awk '{ print $NF }')
		if [[ "$natAirport" != "1" ]] || [[ "$natEnabled" != "1" ]] || [[ "$natPrimary" != "1" ]] || [[ "$forwarding" != "1" ]]; then
			countPassed=$((countPassed + 1))
			result="Passed"
		else
			countFailed=$((countFailed + 1))
			result="Failed"
			comment="Internet Sharing: Enabled"
		fi
	fi
	countPassed=$((countPassed + 1))
	result="Passed"
fi
printReport

CISLevel="1"
audit="2.4.3 Disable Screen Sharing (Automated)"
orgScore="OrgScore2_4_3"
emptyVariables
# Verify organizational score
runAudit
# If organizational score is 1 or true, check status of client
if [[ "${auditResult}" == "1" ]]; then
	method="Script"
	remediate="Script > sudo launchctl disable system/com.apple.screensharing"

	screenSharing=$(launchctl print-disabled system | grep -c '"com.apple.screensharing" => true')
	if [[ "$screenSharing" == "1" ]]; then
		countPassed=$((countPassed + 1))
		result="Passed"
		comment="Screen Sharing: Disabled"
	else
		countFailed=$((countFailed + 1))
		result="Failed"
		comment="Screen Sharing: Enabled"
	fi
fi
printReport

CISLevel="1"
audit="2.4.4 Disable Printer Sharing (Automated)"
orgScore="OrgScore2_4_4"
emptyVariables
# Verify organizational score
runAudit
# If organizational score is 1 or true, check status of client
if [[ "${auditResult}" == "1" ]]; then
	method="Script"
	remediate="Script > sudo /usr/sbin/cupsctl --no-share-printers"

	printerSharing=$(cupsctl | grep "share_printers")
	if [[ "${printerSharing}" == "_share_printers=0" ]]; then
		countPassed=$((countPassed + 1))
		result="Passed"
		comment="Printer Sharing: Disabled"
	else
		countFailed=$((countFailed + 1))
		result="Failed"
		comment="Printer Sharing: Enabled"
	fi
fi
printReport

CISLevel="1"
audit="2.4.5 Disable Remote Login (Automated)"
orgScore="OrgScore2_4_5"
emptyVariables
method="Script"
remediate="Script > sudo /usr/sbin/systemsetup -setremotelogin off"
# Verify organizational score
runAudit
# If organizational score is 1 or true, check status of client
if [[ "${auditResult}" == "1" ]]; then
	screenSharing=$(systemsetup -getremotelogin | grep -c 'Remote Login: Off')
	if [[ "$screenSharing" == "1" ]]; then
		countPassed=$((countPassed + 1))
		result="Passed"
		comment="Remote Login: Disabled"
	else
		countFailed=$((countFailed + 1))
		result="Failed"
		comment="Remote Login: Enabled"
	fi
fi
printReport

CISLevel="1"
audit="2.4.6 Disable DVD or CD Sharing (Automated)"
orgScore="OrgScore2_4_6"
emptyVariables
# Verify organizational score
runAudit
# If organizational score is 1 or true, check status of client
if [[ "${auditResult}" == "1" ]]; then
	method="Script"
	remediate="Script > sudo launchctl unload -w /System/Library/LaunchDaemons/com.apple.ODSAgent.plist"

	discSharing=$(launchctl list | grep -Ec ODSAgent)
	if [[ "${discSharing}" == "0" ]]; then
		countPassed=$((countPassed + 1))
		result="Passed"
		comment="DVD or CD Sharing: Disabled"
	else
		countFailed=$((countFailed + 1))
		result="Failed"
		comment="DVD or CD Sharing: Enabled"
	fi
fi
printReport

CISLevel="1"
audit="2.4.7 Disable Bluetooth Sharing (Automated)"
orgScore="OrgScore2_4_7"
emptyVariables
# Verify organizational score
runAudit
# If organizational score is 1 or true, check status of client
if [[ "${auditResult}" == "1" ]]; then
	method="Script"
	remediate="Script > sudo -u 'CURRENT_USER' defaults -currentHost write com.apple.Bluetooth PrefKeyServicesEnabled -bool false"

	appidentifier="com.apple.Bluetooth"
	value="PrefKeyServicesEnabled"
	prefValueAsUser=$(getPrefValuerunAsUser "${appidentifier}" "${value}")
	prefIsManaged=$(getPrefIsManaged "${appidentifier}" "${value}")
	comment="Bluetooth Sharing: Disabled"
	if [[ "${prefIsManaged}" == "True" && "${prefValueAsUser}" == "False" ]]; then
		countPassed=$((countPassed + 1))
		result="Passed"
	else
		if [[ "${prefValueAsUser}" == "False" ]]; then
			countPassed=$((countPassed + 1))
			result="Passed"
		else
			countFailed=$((countFailed + 1))
			result="Failed"
			comment="Bluetooth Sharing: Enabled"
		fi
	fi
fi
printReport

CISLevel="1"
audit="2.4.8 Disable File Sharing (Automated)"
orgScore="OrgScore2_4_8"
emptyVariables
# Verify organizational score
runAudit
# If organizational score is 1 or true, check status of client
if [[ "${auditResult}" == "1" ]]; then
	method="Script"
	remediate="Script > sudo launchctl disable system/com.apple.smbd"

	smbEnabled=$(launchctl print-disabled system | grep -c '"com.apple.smbd" => false')
	if [[ "${smbEnabled}" == "0" ]]; then
		countPassed=$((countPassed + 1))
		result="Passed"
		comment="File Sharing: Disabled"
	else
		countFailed=$((countFailed + 1))
		result="Failed"
		comment="File Sharing: Enabled"

	fi
fi
printReport

CISLevel="1"
audit="2.4.9 Disable Remote Management (Automated)"
orgScore="OrgScore2_4_9"
emptyVariables
# Verify organizational score
runAudit
# If organizational score is 1 or true, check status of client
if [[ "${auditResult}" == "1" ]]; then
	method="Script"
	remediate="Script > sudo /System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart -deactivate -stop"

	screenSharing=$(runAsUser launchctl list | grep com.apple.RemoteDesktop.agent | awk '{ print $1 }')
	if [[ "$screenSharing" == "-" ]]; then
		countPassed=$((countPassed + 1))
		result="Passed"
		comment="Remote Management: Disabled"
	else
		countFailed=$((countFailed + 1))
		result="Failed"
		comment="Remote Management: Enabled"
	fi
fi
printReport

CISLevel="1"
audit="2.5.1.1 Enable FileVault (Automated)"
orgScore="OrgScore2_5_1_1"
emptyVariables
# Verify organizational score
runAudit
# If organizational score is 1 or true, check status of client
if [[ "${auditResult}" == "1" ]]; then
	method="Profile"
	remediate="Configuration profile - payload > com.apple.MCX.FileVault2 > Enable=On"

	appidentifier="com.apple.MCX.FileVault2"
	value="Enable"
	prefValue=$(getPrefValue "${appidentifier}" "${value}")
	prefIsManaged=$(getPrefIsManaged "${appidentifier}" "${value}")
	comment="FileVault: Enabled"
	if [[ "${prefIsManaged}" == "True" && "${prefValue}" == "On" ]]; then
		countPassed=$((countPassed + 1))
		result="Passed"
	else
		if [[ "${prefValue}" == "On" ]]; then
			countPassed=$((countPassed + 1))
			result="Passed"
		else
			filevaultEnabled=$(fdesetup status | grep -c "FileVault is On.")
			if [[ "$filevaultEnabled" == "1" ]]; then
				countPassed=$((countPassed + 1))
				result="Passed"
			else
				countFailed=$((countFailed + 1))
				result="Failed"
				comment="FileVault: Disabled"
			fi
		fi
	fi
fi
printReport

CISLevel="1"
audit="2.5.1.2 Ensure all user storage APFS volumes are encrypted (Manual)"
orgScore="OrgScore2_5_1_2"
emptyVariables
# Verify organizational score
runAudit
# If organizational score is 1 or true, check status of client
if [[ "${auditResult}" == "1" ]]; then
	apfsyes=$(diskutil ap list)
	if [[ "$apfsyes" != "No APFS Containers found" ]]; then
		startupEncrypted=$(diskutil info / | awk '/FileVault/ {print $2}')
		if [[ "$startupEncrypted" == "Yes" ]]; then
			countPassed=$((countPassed + 1))
			result="Passed"
			comment="Startup Volume: Encrypted"
		else
			countFailed=$((countFailed + 1))
			result="Failed"
			comment="Ensure all user storage APFS Volumes are encrypted"
		fi 
	else 
		countNotice=$((countNotice + 1))
		result="Not applicable"
		comment="Volumes: CoreStorage"
	fi
fi
printReport

CISLevel="1"
audit="2.5.1.3 Ensure all user storage CoreStorage volumes are encrypted (Manual)"
orgScore="OrgScore2_5_1_3"
emptyVariables
# Verify organizational score
runAudit
# If organizational score is 1 or true, check status of client
if [[ "${auditResult}" == "1" ]]; then
	apfsyes=$(diskutil ap list)
	if [[ "$apfsyes" == "No APFS Containers found" ]]; then
		# get Logical Volume Family
		LFV=$(diskutil cs list | grep "Logical Volume Family" | awk '/Logical Volume Family/ {print $5}')
		# Check encryption status is complete
		EncryptStatus=$(diskutil cs "$LFV" | awk '/Conversion Status/ {print $3}')
		if [[ "$EncryptStatus" != "Complete" ]]; then
			countFailed=$((countFailed + 1))
			result="Failed"
			comment="Ensure all user CoreStorage volumes encrypted"
		else 
			countPassed=$((countPassed + 1))
			result="Passed"
			comment="All user CoreStorage volumes encrypted"
		fi
	else 
		countNotice=$((countNotice + 1))
		result="Not applicable"
		comment="Volumes: APFS"
	fi
fi
printReport

CISLevel="1"
audit="2.5.2.1 Enable Gatekeeper (Automated)"
orgScore="OrgScore2_5_2_1"
emptyVariables
# Verify organizational score
runAudit
# If organizational score is 1 or true, check status of client
if [[ "${auditResult}" == "1" ]]; then
	method="Profile"
	remediate="Configuration profile - payload > com.apple.systempolicy.control > EnableAssessment=true"

	appidentifier="com.apple.systempolicy.control"
	value="EnableAssessment"
	prefValue=$(getPrefValue "${appidentifier}" "${value}")
	prefIsManaged=$(getPrefIsManaged "${appidentifier}" "${value}")
	comment="Gatekeeper: Enabled"
	if [[ "${prefIsManaged}" == "True" && "${prefValue}" == "1" ]]; then
		countPassed=$((countPassed + 1))
		result="Passed"
	else
		if [[ "${prefValue}" == "1" ]]; then
			countPassed=$((countPassed + 1))
			result="Passed"
		else
			gatekeeperEnabled=$(spctl --status 2>&1 | grep -c "assessments enabled")
			if [[ "$gatekeeperEnabled" = "1" ]]; then
				countPassed=$((countPassed + 1))
				result="Passed"
			else
				countFailed=$((countFailed + 1))
				result="Failed"
				comment="Gatekeeper: Disabled"
			fi
		fi
	fi
fi
printReport

CISLevel="1"
audit="2.5.2.2 Enable Firewall (Automated)"
orgScore="OrgScore2_5_2_2"
emptyVariables
# Verify organizational score
runAudit
# If organizational score is 1 or true, check status of client
if [[ "${auditResult}" == "1" ]]; then
	method="Profile"
	remediate="Configuration profile - payload > com.apple.security.firewall > EnableFirewall=true"

	appidentifier="com.apple.security.firewall"
	value="EnableFirewall"
	prefValue=$(getPrefValue "${appidentifier}" "${value}")
	prefIsManaged=$(getPrefIsManaged "${appidentifier}" "${value}")
	comment="Firewall: Enabled"
	if [[ "${prefIsManaged}" == "True" && "${prefValue}" == "True" ]]; then
		countPassed=$((countPassed + 1))
		result="Passed"
	else
		if [[ "${prefValue}" == "1" ]]; then
			countPassed=$((countPassed + 1))
			result="Passed"
		else
			countFailed=$((countFailed + 1))
			result="Failed"
			comment="Firewall: Disabled"
		fi
	fi
fi
printReport

CISLevel="1"
audit="2.5.2.3 Enable Firewall Stealth Mode (Automated)"
orgScore="OrgScore2_5_2_3"
emptyVariables
# Verify organizational score
runAudit
if [[ "${auditResult}" == "1" ]]; then
	method="Profile"
	remediate="Configuration profile - payload > com.apple.security.firewall > EnableStealthMode=true"

	appidentifier="com.apple.security.Firewall"
	value="EnableStealthMode"
	prefValue=$(getPrefValue "${appidentifier}" "${value}")
	prefIsManaged=$(getPrefIsManaged "${appidentifier}" "${value}")
	comment="Firewall Stealth Mode: Enabled"
	if [[ "${prefIsManaged}" == "True" && "${prefValue}" == "True" ]]; then
		countPassed=$((countPassed + 1))
		result="Passed"
	else
		if [[ "${prefValue}" == "True" ]]; then
			countPassed=$((countPassed + 1))
			result="Passed"
		else
			stealthEnabled=$(/usr/libexec/ApplicationFirewall/socketfilterfw --getstealthmode | grep -c "Stealth mode enabled")
			if [[ "$stealthEnabled" == "1" ]]; then
				countPassed=$((countPassed + 1))
				result="Passed"
			else
				countFailed=$((countFailed + 1))
				result="Failed"
				comment="Firewall Stealth Mode: Disabled"
			fi
		fi
	fi
fi
printReport

CISLevel="1"
audit="2.5.3 Review Application Firewall Rules (Manual)"
orgScore="OrgScore2_5_3"
emptyVariables
# Verify organizational score
runAudit
# If organizational score is 1 or true, check status of client
if [[ "${auditResult}" == "1" ]]; then
	method="Profile"
	remediate="Configuration profile - payload > com.apple.security.firewall > Applications > Array > BundleID=com.apple.app > Allowed=false"

	appsInbound=$(/usr/libexec/ApplicationFirewall/socketfilterfw --listapps | grep ALF | awk '{print $7}')
	if [[ "${appsInbound}" -le "10" || -z "${appsInbound}" ]]; then
		countPassed=$((countPassed + 1))
		result="Passed"
		comment="Application Firewall Rules: ${appsInbound} Application Managed"
	else 
		countFailed=$((countFailed + 1))
		result="Failed"
		comment="Application Firewall Rules: ${appsInbound} Application Managed"
	fi
fi
printReport

CISLevel="2"
audit="2.5.4 Enable Location Services (Automated)"
orgScore="OrgScore2_5_4"
emptyVariables
# Verify organizational score
runAudit
# If organizational score is 1 or true, check status of client
if [[ "${auditResult}" == "1" ]]; then
	method="Script"
	remediate="Script > sudo /usr/bin/defaults write /var/db/locationd/Library/Preferences/ByHost/com.apple.locationd LocationServicesEnabled -bool true && sudo /bin/launchctl kickstart -k system/com.apple.locationd"
	
	locationServices=$(defaults read /var/db/locationd/Library/Preferences/ByHost/com.apple.locationd.plist LocationServicesEnabled 2>&1)
	if [[ "${locationServices}" != "0" ]]; then
		countPassed=$((countPassed + 1))
		result="Passed"
		comment="Location Services: Enabled"
	else 
		countFailed=$((countFailed + 1))
		result="Failed"
		comment="Location Services: Disabled"
	fi
fi
printReport

CISLevel="2"
audit="2.5.5 Monitor Location Services Access (Manual)"
orgScore="OrgScore2_5_5"
emptyVariables
# Verify organizational score
runAudit
# If organizational score is 1 or true, check status of client
if [[ "${auditResult}" == "1" ]]; then
	method="Manual"
	remediate="Disable unnecessary applications from accessing location services"
	
	locationServices=$(defaults read /var/db/locationd/clients.plist 2>&1 | grep -c "Authorized")
	if [[ "${locationServices}" != "0" ]]; then
		countNotice=$((countNotice + 1))
		result="Notice"
		comment="${locationServices} applications can accessing location services"
	else 
		countPassed=$((countPassed + 1))
		result="Passed"
		comment="No Location Services Access"
	fi
fi
printReport

CISLevel="2"
audit="2.5.6 Disable sending diagnostic and usage data to Apple (Automated)"
orgScore="OrgScore2_5_6"
emptyVariables
# Verify organizational score
runAudit
if [[ "${auditResult}" == "1" ]]; then
	method="Profile"
	remediate="Configuration profile - payload > com.apple.SubmitDiagInfo > AutoSubmit=false - payload > com.apple.applicationaccess > allowDiagnosticSubmission=false"

	appidentifier="com.apple.SubmitDiagInfo"
	value="AutoSubmit"
	prefValue=$(getPrefValue "${appidentifier}" "${value}")
	prefIsManaged=$(getPrefIsManaged "${appidentifier}" "${value}")
	comment="Sending diagnostic and usage data to Apple: Disabled"
	if [[ "${prefIsManaged}" == "True" && "${prefValue}" == "False" ]]; then
		countPassed=$((countPassed + 1))
		result="Passed"
	else
		if [[ "${prefValue}" == "False" ]]; then
			countPassed=$((countPassed + 1))
			result="Passed"
		else
			diagnosticEnabled=$(defaults read /Library/Application\ Support/CrashReporter/DiagnosticMessagesHistory.plist AutoSubmit)
			if [[ "${diagnosticEnabled}" == "0" ]]; then
				countPassed=$((countPassed + 1))
				result="Passed"
			else
				countFailed=$((countFailed + 1))
				result="Failed"
				comment="Sending diagnostic and usage data to Apple: Enabled"
			fi
		fi
	fi
fi
printReport

CISLevel="1"
audit="2.5.7 Limit Ad tracking and personalized Ads (Automated)"
orgScore="OrgScore2_5_7"
emptyVariables
# Verify organizational score
runAudit
# If organizational score is 1 or true, check status of client
if [[ "${auditResult}" == "1" ]]; then
	method="Profile"
	remediate="Configuration profile - payload > com.apple.AdLib > allowApplePersonalizedAdvertising=false"

	appidentifier="com.apple.AdLib"
	value="allowApplePersonalizedAdvertising"
	prefValueAsUser=$(getPrefValuerunAsUser "${appidentifier}" "${value}")
	prefIsManaged=$(getPrefIsManaged "${appidentifier}" "${value}")
	comment="Limited Ad Tracking: Disabled"
	if [[ "${prefIsManaged}" == "True" && "${prefValueAsUser}" == "False" ]]; then
		countPassed=$((countPassed + 1))
		result="Passed"
	else
		if [[ "${prefValueAsUser}" == "False" ]]; then
			countPassed=$((countPassed + 1))
			result="Passed"
		else
			countFailed=$((countFailed + 1))
			result="Failed"
			comment="Limited Ad Tracking: Enabled"
		fi
	fi
fi
printReport

CISLevel="2"
audit="2.6.1 iCloud configuration (Manual)"
orgScore="OrgScore2_6_1"
emptyVariables
# Verify organizational score
runAudit
# If organizational score is 1 or true, check status of client
if [[ "${auditResult}" == "1" ]]; then
	over500=$(dscl . list /Users UniqueID 2>&1 | /usr/bin/awk '$2 > 500 { print $1 }')
	for EachUser in $over500 ;
	do
		UserHomeDirectory=$(dscl . -read /Users/"$EachUser" NFSHomeDirectory 2>&1 | /usr/bin/awk '{print $2}')
		CheckForiCloudAccount=$(defaults read "$UserHomeDirectory/Library/Preferences/MobileMeAccounts" Accounts 2>&1 | /usr/bin/grep -c 'AccountDescription = iCloud')
		# If client fails, then note category in audit file
		if [[ "${CheckForiCloudAccount}" -gt "0" ]] ; then
			countFailed=$((countFailed + 1))
			result="Failed"
			comment="${CheckForiCloudAccount} iCloud account(s) configured"
		else
			countPassed=$((countPassed + 1))
			result="Passed"
			comment="no iCloud account(s) configured"
			fi
	done
fi
printReport

CISLevel="2"
audit="2.6.2 iCloud keychain (Manual)"
orgScore="OrgScore2_6_2"
emptyVariables
# Verify organizational score
runAudit
# If organizational score is 1 or true, check status of client
if [[ "${auditResult}" == "1" ]]; then
	method="Profile"
	remediate="Configuration profile - payload > com.apple.applicationaccess) allowCloudKeychainSync=false"

	appidentifier="com.apple.applicationaccess"
	value="allowCloudKeychainSync"
	prefValue=$(getPrefValue "${appidentifier}" "${value}")
	prefIsManaged=$(getPrefIsManaged "${appidentifier}" "${value}")
	comment="iCloud keychain: Disabled"
	if [[ "${prefIsManaged}" == "True" && "${prefValue}" == "False" ]]; then
		countPassed=$((countPassed + 1))
		result="Passed"
	else
		if [[ "${prefValue}" == "False" ]]; then
			countPassed=$((countPassed + 1))
			result="Passed"
	else
		countFailed=$((countFailed + 1))
		result="Failed"
		comment="iCloud keychain: Enabled"
		fi
	fi
fi
printReport

CISLevel="2"
audit="2.6.3 iCloud Drive (Manual)"
orgScore="OrgScore2_6_3"
emptyVariables
# Verify organizational score
runAudit
# If organizational score is 1 or true, check status of client
if [[ "${auditResult}" == "1" ]]; then
	method="Profile"
	remediate="Configuration profile - payload > com.apple.applicationaccess > allowCloudDocumentSync=false"

	appidentifier="com.apple.applicationaccess"
	value="allowCloudDocumentSync"
	prefValue=$(getPrefValue "${appidentifier}" "${value}")
	prefIsManaged=$(getPrefIsManaged "${appidentifier}" "${value}")
	comment="iCloud Drive: Disabled"
	if [[ "${prefIsManaged}" == "True" && "${prefValue}" == "False" ]]; then
		countPassed=$((countPassed + 1))
		result="Passed"
	else
		if [[ "${prefValue}" == "False" ]]; then
			countPassed=$((countPassed + 1))
			result="Passed"
	else
			countFailed=$((countFailed + 1))
			result="Failed"
			comment="iCloud Drive: Enabled"
		fi
	fi
fi
printReport

CISLevel="2"
audit="2.6.4 iCloud Drive Document and Desktop sync (Manual)"
orgScore="OrgScore2_6_4"
emptyVariables
# Verify organizational score
runAudit
# If organizational score is 1 or true, check status of client
if [[ "${auditResult}" == "1" ]]; then
	method="Profile"
	remediate="Configuration profile - payload > com.apple.applicationaccess > allowCloudDesktopAndDocuments=false"

	appidentifier="com.apple.applicationaccess"
	value="allowCloudDesktopAndDocuments"
	prefValue=$(getPrefValue "${appidentifier}" "${value}")
	prefIsManaged=$(getPrefIsManaged "${appidentifier}" "${value}")
	comment="iCloud Drive Document and Desktop sync: Disabled"
	if [[ "${prefIsManaged}" == "True" && "${prefValue}" == "False" ]]; then
		countPassed=$((countPassed + 1))
		result="Passed"
	else
		if [[ "${prefValue}" == "False" ]]; then
			countPassed=$((countPassed + 1))
			result="Passed"
		else
			countFailed=$((countFailed + 1))
			result="Failed"
			comment="iCloud Drive Document and Desktop sync: Enabled"
		fi
	fi
fi
printReport

CISLevel="2"
audit="2.7.1 Time Machine Auto-Backup (Automated)"
orgScore="OrgScore2_7_1"
emptyVariables
# Verify organizational score
runAudit
# If organizational score is 1 or true, check status of client
if [[ "${auditResult}" == "1" ]]; then
	method="Script"
	remediate="Script > sudo defaults write /Library/Preferences/com.apple.TimeMachine.plist AutoBackup 1"

	timeMachineAuto=$(defaults read /Library/Preferences/com.apple.TimeMachine.plist AutoBackup 2>&1)
	if [[ "$timeMachineAuto" != "0" ]]; then
		countPassed=$((countPassed + 1))
		result="Passed"
		comment="Time Machine Auto-Backup: Enabled"
	else 
		countFailed=$((countFailed + 1))
		result="Failed"
		comment="Time Machine Auto-Backup: Disabled"
	fi
fi
printReport

CISLevel="1"
audit="2.7.2 Time Machine Volumes Are Encrypted (Automated)"
orgScore="OrgScore2_7_2"
emptyVariables
# Verify organizational score
runAudit
# If organizational score is 1 or true, check status of client
if [[ "${auditResult}" == "1" ]]; then
	method="Manual"
	remediate="Manual > Set encryption through Disk Utility or diskutil in terminal"
	
	tmDestination=$(tmutil destinationinfo | grep -i NAME | awk '{print $2}')
	tmDrives=$(tmutil destinationinfo | grep -c "NAME")
	tmVolumeEncrypted=$(diskutil info "${tmDestination}" 2>&1 | grep -c "Encrypted: Yes")
	if [[ "${tmDrives}" -gt "0" && "${tmVolumeEncrypted}" -gt "0" ]]; then
		countPassed=$((countPassed + 1))
		result="Passed"
		comment="Time Machine Volumes: Encrypted"
	else 
		if [[ "${tmDrives}" == "0" ]]; then
			countPassed=$((countPassed + 1))
			result="Passed"
			comment="No Time Machine Volumes available"
		else
			countFailed=$((countFailed + 1))
			result="Failed"
			comment="Time Machine Volumes: Unencrypted"
		fi
	fi
fi
printReport

CISLevel="1"
audit="2.8 Disable Wake for network access (Automated)"
orgScore="OrgScore2_8"
emptyVariables
# Verify organizational score
runAudit
# If organizational score is 1 or true, check status of client
if [[ "${auditResult}" == "1" ]]; then
	method="Script"
	remediate="Script > sudo /usr/bin/pmset -a womp 0"
	
	wakeNetwork=$(pmset -g | awk '/womp/ { sum+=$2 } END {print sum}')
	if [[ "${wakeNetwork}" == "0" ]]; then
		countPassed=$((countPassed + 1))
		result="Passed"
		comment="Wake for network access: Disabled"
	else
		countFailed=$((countFailed + 1))
		result="Failed"
		comment="Wake for network access: Enabled"
	fi
fi
printReport

CISLevel="1"
audit="2.9 Disable Power Nap (Automated)"
orgScore="OrgScore2_9"
emptyVariables
# Verify organizational score
runAudit
# If organizational score is 1 or true, check status of client
if [[ "${auditResult}" == "1" ]]; then
	method="Script"
	remediate="Script > sudo /usr/bin/pmset -a powernap 0"
	
	powerNap=$(pmset -g custom | awk '/powernap/ { sum+=$2 } END {print sum}')
	if [[ "${powerNap}" == "0" ]]; then
		countPassed=$((countPassed + 1))
		result="Passed"
		comment="Power Nap: Enabled"
	else 
		countFailed=$((countFailed + 1))
		result="Failed"
		comment="Power Nap: Disabled"
	fi
fi
printReport

CISLevel="1"
audit="3.1 Enable security auditing (Automated)"
orgScore="OrgScore3_1"
emptyVariables
# Verify organizational score
runAudit
# If organizational score is 1 or true, check status of client
if [[ "${auditResult}" == "1" ]]; then
	method="Script"
	remediate="Script > sudo launchctl load -w /System/Library/LaunchDaemons/com.apple.auditd.plist"

	auditdEnabled=$(launchctl list 2>&1 | grep -c auditd)
	if [[ "${auditdEnabled}" -gt "0" ]]; then
		countPassed=$((countPassed + 1))
		result="Passed"
		comment="Security auditing: Enabled"
	else 
		countFailed=$((countFailed + 1))
		result="Failed"
		comment="Security auditing: Disabled"
	fi
fi
printReport

CISLevel="2"
audit="3.2 Configure Security Auditing Flags per local organizational requirements (Manual)"
orgScore="OrgScore3_2"
emptyVariables
# Verify organizational score
runAudit
# If organizational score is 1 or true, check status of client
if [[ "${auditResult}" == "1" ]]; then
	method="Script"
	remediate="Script > sudo /usr/bin/sed -i.bak '/^flags/ s/$/,ad/' /etc/security/audit_control /usr/sbin/audit -s"

	auditFlags="$(grep -c "^flags:" /etc/security/audit_control)"
	if [[ "${auditFlags}" == "1" ]]; then
		countPassed=$((countPassed + 1))
		result="Passed"
		comment="Security Auditing Flags: Enabled"
	else 
		countFailed=$((countFailed + 1))
		result="Failed"
		comment="Security Auditing Flags: Disabled"
	fi
fi
printReport

CISLevel="1"
audit="3.3 Retain install.log for 365 or more days with no maximum size (Automated)"
orgScore="OrgScore3_3"
emptyVariables
# Verify organizational score
runAudit
# If organizational score is 1 or true, check status of client
if [[ "${auditResult}" == "1" ]]; then
	method="Script"
	remediate="Script > add 'ttl=365' to /etc/asl/com.apple.install"
	
	installRetention="$(grep -c ttl=365 /etc/asl/com.apple.install)"
	if [[ "${installRetention}" = "1" ]]; then
		countPassed=$((countPassed + 1))
		result="Passed"
		comment="Retain install.log: 365 or more days"
	else 
		countFailed=$((countFailed + 1))
		result="Failed"
		comment="Retain install.log: Less than 365 days"
	fi
fi
printReport

CISLevel="1"
audit="3.4 Ensure security auditing retention (Automated)"
orgScore="OrgScore3_4"
emptyVariables
# Verify organizational score
runAudit
# If organizational scorse is 1 or true, check status of client
if [[ "${auditResult}" == "1" ]]; then
	method="Script"
	remediate="Script > add 'expire-after:60d OR 1G' to /etc/security/audit_control"

	auditRetention="$(grep -c expire-after /etc/security/audit_control)"	
	if [[  "${auditRetention}" == "1" ]]; then
		countPassed=$((countPassed + 1))
		result="Passed"
		comment="Security auditing retention: Configured"
	else 
		countFailed=$((countFailed + 1))
		result="Failed"
		comment="Security auditing retention: Unconfigured"
	fi
fi
printReport

CISLevel="1"
audit="3.5 Control access to audit records (Automated)"
orgScore="OrgScore3_5"
emptyVariables
# Verify organizational score
runAudit
# If organizational score is 1 or true, check status of client
if [[ "${auditResult}" == "1" ]]; then
	method="Script"
	remediate="Script > sudo chown -R root $(/usr/bin/grep '^dir' /etc/security/audit_control | /usr/bin/awk -F: '{print $2}')"

	controlAccess=$(grep '^dir' /etc/security/audit_control | awk -F: '{print $2}')
	accessCheck=$(find "${controlAccess}" | awk '{s+=$3} END {print s}')
	if [[ "${accessCheck}" == "0" ]]; then
		countPassed=$((countPassed + 1))
		result="Passed"
		comment="Control access to audit records: Correct ownership"
	else 
		countFailed=$((countFailed + 1))
		result="Failed"
		comment="Control access to audit records: Incorrect ownership"
	fi
fi
printReport

CISLevel="1"
audit="3.6 Ensure Firewall is configured to log (Automated)"
orgScore="OrgScore3_6"
emptyVariables
# Verify organizational score
runAudit
# If organizational score is 1 or true, check status of client
if [[ "${auditResult}" == "1" ]]; then
	method="Script"
	remediate="Script > sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setloggingmode on"

	FWlog=$(/usr/libexec/ApplicationFirewall/socketfilterfw --getloggingmode | grep -c "Log mode is on")
	if [[ "$FWlog" = "1" ]]; then
		countPassed=$((countPassed + 1))
		result="Passed"
		comment="Firewall logging: Enabled"
	else 
		countFailed=$((countFailed + 1))
		result="Failed"
		comment="Firewall logging: Disabled"

		# Remediation
		/usr/libexec/ApplicationFirewall/socketfilterfw --setloggingmode on
		countRemediated=$((countRemediated + 1))
		# re-check
		FWlog=$(/usr/libexec/ApplicationFirewall/socketfilterfw --getloggingmode | grep -c "Log mode is on")
		printCLIResult=$(systemsetup -getnetworktimeserver)
		if [[ "$FWlog" = "1" ]]; then
			Remediated
			result="Passed After Remdiation"
			comment="Firewall logging: Enabled"
		else
			countFailedAfterRemediation=$((countFailedAfterRemediation + 1))
			result="FailedAfterRemediation"
			comment="Firewall logging: Disabled"
		fi
	fi
fi
printReport

CISLevel="2"
audit="4.1 Disable Bonjour advertising service (Automated)"
orgScore="OrgScore4_1"
emptyVariables
# Verify organizational score
runAudit
# If organizational score is 1 or true, check status of client
if [[ "${auditResult}" == "1" ]]; then
	method="Profile"
	remediate="Configuration profile - payload > com.apple.mDNSResponder > NoMulticastAdvertisements=true"

	appidentifier="com.apple.mDNSResponder"
	value="NoMulticastAdvertisements"
	prefValue=$(getPrefValue "${appidentifier}" "${value}")
	prefIsManaged=$(getPrefIsManaged "${appidentifier}" "${value}")
	comment="Bonjour advertising service: Disable"
	if [[ "${prefIsManaged}" == "True" && "${prefValue}" == "True" ]]; then
		countPassed=$((countPassed + 1))
		result="Passed"
	else
		if [[ "${prefValue}" == "True" ]]; then
			countPassed=$((countPassed + 1))
			result="Passed"
		else
			countFailed=$((countFailed + 1))
			result="Failed"
			comment="Bonjour advertising service: Enabled"
		fi
	fi
fi
printReport

CISLevel="1"
audit='4.2 Enable "Show Wi-Fi status in menu bar" (Automated)'
orgScore="OrgScore4_2"
emptyVariables
# Verify organizational score
runAudit
# If organizational score is 1 or true, check status of client
if [[ "${auditResult}" == "1" ]]; then
	method="Script"
	remediate="Script > sudo -u <username> defaults -currentHost write com.apple.controlcenter.plist WiFi -int 18"
	
	appidentifier="com.apple.controlcenter"
	value="NSStatusItem Visible WiFi"
	prefValue=$(getPrefValuerunAsUser "${appidentifier}" "${value}")
	prefIsManaged=$(getPrefIsManaged "${appidentifier}" "${value}")
	comment="Wi-Fi status in menu bar: Enabled"
	if [[ "${prefIsManaged}" == "True" && "${prefValue}" == "True" ]]; then
		countPassed=$((countPassed + 1))
		result="Passed"
	else
		if [[ "${prefValue}" == "True" ]]
		then
			countPassed=$((countPassed + 1))
			result="Passed"
		else
			countFailed=$((countFailed + 1))
			result="Failed"
			comment="Wi-Fi status in menu bar: Disabled"
		fi
	fi
fi
printReport

CISLevel="1"
audit="4.4 Ensure http server is not running (Automated)"
orgScore="OrgScore4_4"
emptyVariables
# Verify organizational score
runAudit
# If organizational score is 1 or true, check status of client
if [[ "${auditResult}" == "1" ]]; then
	method="Script"
	remediate="Script > sudo launchctl disable system/org.apache.httpd"

	httpServer=$(launchctl print-disabled system 2>&1 | grep -c '"org.apache.httpd" => true')
#	httpServer=$(launchctl list 2>&1 | grep -c httpd)
	if [[ "${httpServer}" == "1" ]]; then
		countPassed=$((countPassed + 1))
		result="Passed"
		comment="HTTP server service: Disabled"
	else 
		countFailed=$((countFailed + 1))
		result="Failed"
		comment="HTTP server service: Enabled"
	fi
fi
printReport

CISLevel="1"
audit="4.5 Ensure nfs server is not running. (Automated)"
orgScore="OrgScore4_5"
emptyVariables
# Verify organizational score
runAudit
# If organizational score is 1 or true, check status of client
if [[ "${auditResult}" == "1" ]]; then
	method="Script"
	remediate="Script > sudo launchctl disable system/com.apple.nfsd && sudo rm /etc/exports"

	httpServer=$(launchctl print-disabled system 2>&1 | grep -c '"com.apple.nfsd" => true')
	if [[ "${httpServer}" == "1" ]]; then
		countPassed=$((countPassed + 1))
		result="Passed"
		comment="NFS server service: Disabled"
	else 
		countFailed=$((countFailed + 1))
		result="Failed"
		comment="NFS server service: Enabled"
	fi
fi
printReport

CISLevel="2"
audit="5.10 Ensure system is set to hibernate (Automated)"
orgScore="OrgScore5_10"
emptyVariables
# Verify organizational score
runAudit
# If organizational score is 1 or true, check status of client
if [[ "${auditResult}" == "1" ]]; then
	method="Script"
	remediate="Script > sudo pmset -a standbydelayhigh 600 && sudo pmset -a standbydelaylow 600 && sudo pmset -a highstandbythreshold 90 && sudo pmset -a destroyfvkeyonstandby 1"

	hibernateValue=$(pmset -g | grep standbydelaylow 2>&1 | awk '{print $2}')
	macType=$(system_profiler SPHardwareDataType 2>&1 | grep -c MacBook)
	comment="Hibernate: Enabled"
	if [[ "$macType" -ge 0 ]]; then
		if [[ "$hibernateValue" == "" ]] || [[ "$hibernateValue" -gt 600 ]]; then
			countPassed=$((countPassed + 1))
			result="Passed"
		else 
			countFailed=$((countFailed + 1))
			result="Failed"
			comment="Hibernate: Disabled"
		fi
	else
		countPassed=$((countPassed + 1))
		result="Passed"
	fi
fi
printReport

CISLevel="1"
audit="5.11 Require an administrator password to access system-wide preferences (Automated)"
orgScore="OrgScore5_11"
emptyVariables
# Verify organizational score
runAudit
# If organizational score is 1 or true, check status of client
if [[ "${auditResult}" == "1" ]]; then
	method="Script"
	remediate="Script > sudo security authorizationdb read system.preferences > /tmp/system.preferences.plist && sudo defaults write /tmp/system.preferences.plist shared -bool false && sudo security authorizationdb write system.preferences < /tmp/system.preferences.plist"

	adminSysPrefs="$(security authorizationdb read system.preferences 2> /dev/null | grep -A 1 "<key>shared</key>" | grep -c "<false/>")"
	if [[ "${adminSysPrefs}" == "1" ]]; then
		countPassed=$((countPassed + 1))
		result="Passed"
		comment="Require an administrator password to access system-wide preferences: Enabled"
	else 
		countFailed=$((countFailed + 1))
		result="Failed"
		comment="Require an administrator password to access system-wide preferences: Disabled"
	fi
fi
printReport

CISLevel="1"
audit="5.12 Ensure an administrator account cannot login to another user's active and locked session (Automated)"
orgScore="OrgScore5_12"
emptyVariables
# Verify organizational score
runAudit
# If organizational score is 1 or true, check status of client
if [[ "${auditResult}" == "1" ]]; then
	method="Script"
	remediate="Script > sudo security authorizationdb write system.login.screensaver 'use-login-window-ui'"

	screensaverRules="$(security authorizationdb read system.login.screensaver 2>&1 | grep -c 'use-login-window-ui')"
	if [[ "${screensaverRules}" == "1" ]]; then
		countPassed=$((countPassed + 1))
		result="Passed"
		comment="Ability to login to another user's active and locked session: Disabled"
	else 
		countFailed=$((countFailed + 1))
		result="Failed"
		comment="Ability to login to another user's active and locked session: Enabled"
	fi
fi
printReport

CISLevel="1"
audit="5.13 Create a custom message for the Login Screen (Automated)"
orgScore="OrgScore5_13"
emptyVariables
# Verify organizational score
runAudit
# If organizational score is 1 or true, check status of client
if [[ "${auditResult}" == "1" ]]; then
	method="Profile"
	remediate="Configuration profile - payload > com.apple.loginwindow > LoginwindowText='message'"

	appidentifier="com.apple.loginwindow"
	value="LoginwindowText"
	prefValueAsUser=$(getPrefValuerunAsUser "${appidentifier}" "${value}")
	prefIsManaged=$(getPrefIsManaged "${appidentifier}" "${value}")
	comment="Custom message for the Login Screen: Enabled"
	if [[ "${prefIsManaged}" == "True" && "${prefValueAsUser}" != "" ]]; then
		countPassed=$((countPassed + 1))
		result="Passed"
	else
		if [[ "${prefValueAsUser}" != "" ]]
		then
			countPassed=$((countPassed + 1))
			result="Passed"
		else
			countFailed=$((countFailed + 1))
			result="Failed"
			comment="Custom message for the Login Screen: Disabled"
		fi
	fi
fi
printReport

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

CISLevel="2"
audit="5.16 Disable Fast User Switching (Manual)"
orgScore="OrgScore5_16"
emptyVariables
# Verify organizational score
runAudit
# If organizational score is 1 or true, check status of client
if [[ "${auditResult}" == "1" ]]; then
	method="Profile"
	remediate="Configuration profile - payload > .GlobalPreferences > MultipleSessionEnabled=false"

	appidentifier=".GlobalPreferences"
	value="MultipleSessionEnabled"
	prefValueAsUser=$(getPrefValuerunAsUser "${appidentifier}" "${value}")
	prefIsManaged=$(getPrefIsManaged "${appidentifier}" "${value}")
	comment="Fast User Switching: Disabled"
	if [[ "${prefIsManaged}" == "True" && "${prefValueAsUser}" == "False" ]]; then
		countPassed=$((countPassed + 1))
		result="Passed"
	else
		if [[ "${prefValue}" == "False" ]]
		then
			countPassed=$((countPassed + 1))
			result="Passed"
		else
			countFailed=$((countFailed + 1))
			result="Failed"
			comment="Fast User Switching: Enabled"
		fi
	fi
fi
printReport

CISLevel="2"
audit="5.18 System Integrity Protection status (Automated)"
orgScore="OrgScore5_18"
emptyVariables
# Verify organizational score
runAudit
# If organizational score is 1 or true, check status of client
if [[ "${auditResult}" == "1" ]]; then
	method="Script"
	remediate="Script > sudo /usr/bin/csrutil enable"

	sipEnabled="$(csrutil status 2>&1 | awk '{print $5}')"
	if [[ "${sipEnabled}" == "enabled." ]]; then
		countPassed=$((countPassed + 1))
		result="Passed"
		comment="System Integrity Protection: Enabled"
	else 
		countFailed=$((countFailed + 1))
		result="Failed"
		comment="System Integrity Protection: Disabled"
	fi
fi
printReport

CISLevel="1"
audit="5.1.1 Secure Home Folders (Automated)"
orgScore="OrgScore5_1_1"
emptyVariables
# Verify organizational score
runAudit
# If organizational score is 1 or true, check status of client
if [[ "${auditResult}" == "1" ]]; then
	method="Script"
	remediate="Script > sudo chmod og-rwx 'HomeFolders'"

	homeFolders="$(find /Users -mindepth 1 -maxdepth 1 -type d -perm -1 2>&1 | grep -v "Shared" | grep -v "Guest" | wc -l | xargs)"
	if [[ "${homeFolders}" == "0" ]]; then
		countPassed=$((countPassed + 1))
		result="Passed"
		comment="Home Folders: Secure"
	else 
		countFailed=$((countFailed + 1))
		result="Failed"
		comment="Home Folders: Insecure"
	fi
fi
printReport

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
		countPassed=$((countPassed + 1))
		result="Passed"
		comment="All System Wide Applications have appropriate permissions"
	else 
		countFailed=$((countFailed + 1))
		result="Failed"
		comment="Check permissions of ${appPermissions} system wide Applications"
	fi
fi
printReport

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
		countPassed=$((countPassed + 1))
		result="Passed"
		comment="All System folder for world are not writable files"
	else 
		countFailed=$((countFailed + 1))
		result="Failed"
		comment="Check ${sysPermissions} System folder for world writable files"
	fi
fi
printReport

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
		countPassed=$((countPassed + 1))
		result="Passed"
		comment="All Library folder for world are not writable files"
	else 
		countFailed=$((countFailed + 1))
		result="Failed"
		comment="Check ${libPermissions} Library folders for world writable files"
	fi
fi
printReport

CISLevel="1"
audit="5.3 Reduce the sudo timeout period (Automated)"
orgScore="OrgScore5_3"
emptyVariables
# Verify organizational score
runAudit
# If organizational score is 1 or true, check status of client
if [[ "${auditResult}" == "1" ]]; then
	remediate='Script > echo "Defaults timestamp_timeout=0" >> /etc/sudoers'

	sudoTimeout="$(ls /etc/sudoers.d/ 2>&1 | grep -c timestamp )"
	if [[ "${sudoTimeout}" == "0" ]]; then
		countPassed=$((countPassed + 1))
		result="Passed"
		comment="The sudo timeout period is reduced: ${sudoTimeout}"
	else 
		countFailed=$((countFailed + 1))
		result="Failed"
		comment="Reduce the sudo timeout period"
	fi
fi
printReport

CISLevel="2"
audit="5.4 Automatically lock the login keychain for inactivity (Manual)"
orgScore="OrgScore5_4"
emptyVariables
# Verify organizational score
runAudit
# If organizational score is 1 or true, check status of client
if [[ "${auditResult}" == "1" ]]; then
	method="Script"
	remediate="Script > sudo -u <username> security set-keychain-settings -t 21600 /Users/<username>/Library/Keychains/login.keychain"
	
	keyTimeout="$(security show-keychain-info /Users/"${currentUser}"/Library/Keychains/login.keychain 2>&1 | grep -c "no-timeout")"
	if [[ "${keyTimeout}" == "1" ]]; then
		countPassed=$((countPassed + 1))
		result="Passed"
		comment="Automatically lock the login keychain for inactivity: Enabled"
	else 
		countFailed=$((countFailed + 1))
		result="Failed"
		comment="Automatically lock the login keychain for inactivity: Disabled"
	fi
fi
printReport

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
		countPassed=$((countPassed + 1))
		result="Passed"
		comment="Separate timestamp for each user/tty combo: Enabled"
	else 
		countFailed=$((countFailed + 1))
		result="Failed"
		comment="Separate timestamp for each user/tty combo: Disabled"
	fi
fi
printReport

CISLevel="2"
audit="5.6 Ensure login keychain is locked when the computer sleeps (Manual)"
orgScore="OrgScore5_6"
emptyVariables
# Verify organizational score
runAudit
# If organizational score is 1 or true, check status of client
if [[ "${auditResult}" == "1" ]]; then
	method="Script"
	remediate="Script > sudo -u <username> security set-keychain-settings -l /Users/<username>/Library/Keychains/login.keychain"

	lockSleep="$(security show-keychain-info /Users/"${currentUser}"/Library/Keychains/login.keychain 2>&1 | grep -c "lock-on-sleep")"
	if [[ "${lockSleep}" == "1" ]]; then
		countPassed=$((countPassed + 1))
		result="Passed"
		comment="Login keychain is locked when the computer sleeps: Enabled"
	else 
		countFailed=$((countFailed + 1))
		result="Failed"
		comment="Login keychain is locked when the computer sleeps: Disabled"
	fi
fi
printReport

CISLevel="1"
audit='5.7 Do not enable the "root" account (Automated)'
orgScore="OrgScore5_7"
emptyVariables
# Verify organizational score
runAudit
# If organizational score is 1 or true, check status of client
if [[ "${auditResult}" == "1" ]]; then
	method="Script"
	remediate="Script > sudo dscl . -create /Users/root UserShell /usr/bin/false"

	rootEnabled="$(dscl . -read /Users/root AuthenticationAuthority 2>&1 | grep -c "No such key")"
	rootEnabledRemediate="$(dscl . -read /Users/root UserShell 2>&1 | grep -c "/usr/bin/false")"
	if [[ "${rootEnabled}" == "1" || "${rootEnabledRemediate}" == "1" ]]; then
		countPassed=$((countPassed + 1))
		result="Passed"
		comment="root user account: Disabled"
	else 
		countFailed=$((countFailed + 1))
		result="Failed"
		comment="root user account: Enabled"
	fi
fi
printReport

CISLevel="1"
audit="5.8 Disable automatic login (Automated)"
orgScore="OrgScore5_8"
emptyVariables
# Verify organizational score
runAudit
# If organizational score is 1 or true, check status of client
if [[ "${auditResult}" == "1" ]]; then
	method="Profile"
	remediate="Configuration profile - payload > com.apple.loginwindow> DisableFDEAutoLogin=true"

	appidentifier="com.apple.loginwindow"
	value="DisableFDEAutoLogin"
	prefValueAsUser=$(getPrefValuerunAsUser "${appidentifier}" "${value}")
	prefIsManaged=$(getPrefIsManaged "${appidentifier}" "${value}")
	comment="Automatic login: Disabled"
	if [[ "${prefIsManaged}" == "True" && "${prefValueAsUser}" == "True" ]]; then
		countPassed=$((countPassed + 1))
		result="Passed"
	else
		if [[ "${prefValueAsUser}" == "True" ]]; then
			countPassed=$((countPassed + 1))
			result="Passed"
		else
			automaticLogin=$(defaults read /Library/Preferences/com.apple.loginwindow | grep -c "autoLoginUser")
			if [[ "${automaticLogin}" == "0" ]]; then
				countPassed=$((countPassed + 1))
				result="Passed"
			else
				countFailed=$((countFailed + 1))
				result="Failed"
				comment="Automatic login: Enabled"
			fi
		fi
	fi
fi
printReport

CISLevel="1"
audit="5.9 Require a password to wake the computer from sleep or screen saver (Manual)"
orgScore="OrgScore5_9"
emptyVariables
# Verify organizational score
runAudit
# If organizational score is 1 or true, check status of client
if [[ "${auditResult}" == "1" ]]; then
	method="Profile"
	remediate="Configuration profile - payload > com.apple.screensaver > askForPassword=true"

	appidentifier="com.apple.screensaver"
	value="askForPassword"
	prefValueAsUser=$(getPrefValuerunAsUser "${appidentifier}" "${value}")
	prefIsManaged=$(getPrefIsManaged "${appidentifier}" "${value}")
	comment="Require a password to wake the computer from sleep or screen saver: Enabled"
	if [[ "${prefIsManaged}" == "True" && "${prefValueAsUser}" == "True" ]]; then
		countPassed=$((countPassed + 1))
		result="Passed"
	else
		if [[ "${prefValueAsUser}" == "True" ]]; then
			countPassed=$((countPassed + 1))
			result="Passed"
		else
			passwordWake=$(defaults read /Users/"$currentUser"/Library/Preferences/com.apple.screensaver | grep -c "askForPassword")
			if [[ "${passwordWake}" == "0" ]]; then
				countPassed=$((countPassed + 1))
				result="Passed"
			else
				countFailed=$((countFailed + 1))
				result="Failed"
				comment="Require a password to wake the computer from sleep or screen saver: Disabled"
			fi
		fi
	fi
fi
printReport

CISLevel="1"
audit="6.1.1 Display login window as name and password (Automated)"
orgScore="OrgScore6_1_1"
emptyVariables
# Verify organizational score
runAudit
# If organizational score is 1 or true, check status of client
if [[ "${auditResult}" == "1" ]]; then
	method="Profile"
	remediate="Configuration profile - payload > com.apple.loginwindow > SHOWFULLNAME=true"

	appidentifier="com.apple.loginwindow"
	value="SHOWFULLNAME"
	prefValueAsUser=$(getPrefValuerunAsUser "${appidentifier}" "${value}")
	prefIsManaged=$(getPrefIsManaged "${appidentifier}" "${value}")
	comment="Display login window as name and password: Enabled"
	if [[ "${prefIsManaged}" == "True" && "${prefValueAsUser}" == "True" ]]; then
		countPassed=$((countPassed + 1))
		result="Passed"
	else
		if [[ "${prefValueAsUser}" == "True" ]]
		then
			countPassed=$((countPassed + 1))
			result="Passed"
		else
			countFailed=$((countFailed + 1))
			result="Failed"
			comment="Display login window as name and password: Disabled"
		fi
	fi
fi
printReport

CISLevel="1"
audit='6.1.2 Disable "Show password hints" (Automated)'
orgScore="OrgScore6_1_2"
emptyVariables
# Verify organizational score
runAudit
# If organizational score is 1 or true, check status of client
if [[ "${auditResult}" == "1" ]]; then
	method="Profile"
	remediate="Configuration profile - payload > com.apple.loginwindow > RetriesUntilHint=0"

	appidentifier="com.apple.loginwindow"
	value="RetriesUntilHint"
	prefValueAsUser=$(getPrefValuerunAsUser "${appidentifier}" "${value}")
	prefIsManaged=$(getPrefIsManaged "${appidentifier}" "${value}")
	comment="Show password hints: Disabled"
	if [[ "${prefIsManaged}" == "True" && "${prefValueAsUser}" == "0" ]]; then
		countPassed=$((countPassed + 1))
		result="Passed"
	else
		if [[ "${prefValueAsUser}" == "0" ]]
		then
			countPassed=$((countPassed + 1))
			result="Passed"
		else
			countFailed=$((countFailed + 1))
			result="Failed"
			comment="Show password hints: Enabled"
		fi
	fi
fi
printReport

CISLevel="1"
audit="6.1.3 Disable guest account login (Automated)"
orgScore="OrgScore6_1_3"
emptyVariables
# Verify organizational score
runAudit
# If organizational score is 1 or true, check status of client
if [[ "${auditResult}" == "1" ]]; then
	method="Profile"
	remediate="Configuration profile - payload > com.apple.MCX > DisableGuestAccount=True"

	appidentifier="com.apple.MCX"
	value="DisableGuestAccount"
	prefValue=$(getPrefValuerunAsUser "${appidentifier}" "${value}")
	prefIsManaged=$(getPrefIsManaged "${appidentifier}" "${value}")
	comment="Guest account: Disabled"
	if [[ "${prefIsManaged}" == "True" && "${prefValue}" == "True" ]]; then
		countPassed=$((countPassed + 1))
		result="Passed"
	else
		if [[ "${prefValue}" == "True" ]]
		then
			countPassed=$((countPassed + 1))
			result="Passed"
		else
			countFailed=$((countFailed + 1))
			result="Failed"
			comment="Guest account: Enabled"
		fi
	fi
fi
printReport

CISLevel="1"
audit='6.1.4 Disable "Allow guests to connect to shared folders" (Automated)'
orgScore="OrgScore6_1_4"
emptyVariables
# Verify organizational score
runAudit
# If organizational score is 1 or true, check status of client
if [[ "${auditResult}" == "1" ]]; then
	method="Profile"
	remediate="Configuration profile - payload > com.apple.smb.server AllowGuestAccess=false"
	
	appidentifier="com.apple.smb.server"
	value="AllowGuestAccess"
	prefValue=$(getPrefValue "${appidentifier}" "${value}")
	prefIsManaged=$(getPrefIsManaged "${appidentifier}" "${value}")
	comment="Allow guests to connect to shared folders: Disabled"
	if [[ "${prefIsManaged}" == "True" && "${prefValue}" == "False" ]]; then
		countPassed=$((countPassed + 1))
		result="Passed"
	else
		if [[ "${prefValue}" == "False" ]]
		then
			countPassed=$((countPassed + 1))
			result="Passed"
		else
			countFailed=$((countFailed + 1))
			result="Failed"
			comment="Allow guests to connect to shared folders: Enabled"
		fi
	fi
fi
printReport

CISLevel="1"
audit="6.1.5 Remove Guest home folder (Automated)"
orgScore="OrgScore6_1_5"
emptyVariables
# Verify organizational score
runAudit
# If organizational score is 1 or true, check status of client
if [[ "${auditResult}" == "1" ]]; then
	method="Script"
	remediate="Script > sudo rm -rf /Users/Guest"

	guestHomeFolder="$(ls /Users/ 2>&1 | grep -c Guest)"
	if [[ "${guestHomeFolder}" == "0" ]]; then
		countPassed=$((countPassed + 1))
		result="Passed"
		comment="Guest home folder: Not Available"
	else 
		countFailed=$((countFailed + 1))
		result="Failed"
		comment="Guest home folder: Available"
	fi
fi
printReport

CISLevel="1"
audit="6.2 Turn on filename extensions (Automated)"
orgScore="OrgScore6_2"
emptyVariables
# Verify organizational score
runAudit
# If organizational score is 1 or true, check status of client
if [[ "${auditResult}" == "1" ]]; then
	method="Profile"
	remediate="Configuration profile - payload > .GlobalPreferences > AppleShowAllExtensions=true"

	appidentifier="com.apple.GlobalPreferences"
	value="AppleShowAllExtensions"
	prefValue=$(getPrefValuerunAsUser "${appidentifier}" "${value}")
	prefIsManaged=$(getPrefIsManaged "${appidentifier}" "${value}")
	comment="Show all Filename extensions: Enabled"
	if [[ "${prefIsManaged}" == "True" && "${prefValue}" == "True" ]]; then
		countPassed=$((countPassed + 1))
		result="Passed"
	else
		if [[ "${prefValue}" == "True" ]]
		then
			countPassed=$((countPassed + 1))
			result="Passed"
		else
			countFailed=$((countFailed + 1))
			result="Failed"
			comment="Show all Filename extensions: Disabled"
		fi
	fi
fi
printReport

CISLevel="1"
audit="6.3 Disable the automatic run of safe files in Safari (Automated)"
orgScore="OrgScore6_3"
emptyVariables
# Verify organizational score
runAudit
# If organizational score is 1 or true, check status of client
if [[ "${auditResult}" == "1" ]]; then
	method="Profile"
	remediate="Configuration profile - payload > com.apple.Safari > AutoOpenSafeDownloads=false"

	appidentifier="com.apple.Safari"
	value="AutoOpenSafeDownloads"
	prefValue=$(getPrefValuerunAsUser "${appidentifier}" "${value}")
	prefIsManaged=$(getPrefIsManagedrunAsUser "${appidentifier}" "${value}")
	comment="Automatic run of safe files in Safari: Disabled"
	if [[ "${prefIsManaged}" == "True" && "${prefValue}" == "False" ]]; then
		countPassed=$((countPassed + 1))
		result="Passed"
	else
		if [[ "${prefValue}" == "False" ]]
		then
			countPassed=$((countPassed + 1))
			result="Passed"
		else
			countFailed=$((countFailed + 1))
			result="Failed"
			comment="Automatic run of safe files in Safari: Enabled"
		fi
	fi
fi
printReport
# Creation date CISBenchmarkReport
echo >> "${CISBenchmarkReport}"
echo "Security report - $(date -u)" >> "${CISBenchmarkReport}"

open "${CISBenchmarkReportPath}"
# open -a Numbers "${CISBenchmarkReport}"
# open -a "Microsoft Excel" "${CISBenchmarkReport}"

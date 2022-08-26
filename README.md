# CIS-Script
<img src="https://github.com/mvdbent/CIS-Script/blob/dev/Utils/CIS-Script.png" width="250">

_**Current state of the scripts are:** "This project is 'As is" please be free to give me any feedback_

![GitHub](https://img.shields.io/badge/macOS-11-success)
![GitHub](https://img.shields.io/badge/macOS-12-success)
![GitHub](https://img.shields.io/github/license/mvdbent/CIS-Script)
<!-- ![GitHub](https://img.shields.io/github/v/release/mvdbent/CIS-Script) -->
<!-- ![GitHub](https://img.shields.io/github/downloads/mvdbent/CIS-Script/latest/total) -->
<!-- ![GitHub](https://img.shields.io/badge/macOS-10.15%2B-yellow) -->

## DESCRIPTION
This CIS Script is build to report and remediate based on the your organisation score.

## Info
While working with CIS Benchmarks (Remediation Scripts and/or Configuration Profiles) I felt this could be done better, faster and easier.
The guys from the [macOS Security Compliance Project](https://github.com/usnistgov/macos_security) did an amazing job automating the guidance and configuration profiles.

I created custom rules set for *[CIS Benchmark](https://downloads.cisecurity.org/#/)* to integrate with the macOS Security Compliance Project and published [CIS-macOS-Security](https://github.com/mvdbent/CIS-macOS-Security).

While working with **CIS Benchmark**, **Script** and **Configuration Profile**, I had the feeling there was missing an overview with complete reporting, and therefore built a read-only CIS-Reporting script you can find [here](https://github.com/mvdbent/CIS-Reporting)

The project ended up with separate tools, with the creation of  **Documentation**, **Configuration Profiles** and **Reporting**. However, I still needed an extra script for remediation.

To resolve this I combined the reporting script with remediation with the option to enable remediation or not. 

For easy maintaining, the CIS-Script is built in fragments. There is a `Header.sh`, `Footer.sh`, `Version.sh` and a folder **OrgScore** filled with separate `OrgScore*.sh`. This way it's easier to focus on a specific rule or subset of rules.

To assemble all the fragments together in a script you can use standalone or via an MDM server (like Jamf Pro), you can use the `Assemble.sh` script. After assembling the Remediation Script, standalone it will perform a read-only check and creates a full report. 

```bash
$ sudo ./CISBenchmarkScript.sh
```
*Location of the report `/Library/Security/Reports/`*

If you use the script via an MDM you can set the script to create a short or full report, and enable or disable remediation.

## Usage/Requirements
*The CIS-Script is tested on macOS Big Sur 11.*

* Test OrgScore*.sh
* Assembled Remediation Script
* Upload CIS Benchmark Settings Configuration Profile
* Configure CIS Configuration Profiles.
* Extension Attributes [Jamf Pro Server](https://github.com/mvdbent/CIS-Script/tree/main/Jamf/EA)


### Test OrgScore*.sh
For adjustments, you can test every OrgScore separately.

```bash
$ cd /Git/CIS-Script/Fragments/OrgScores
$ sudo ./OrgScore*.sh
```

### Assemble Remediation Script
The `Assemble.sh` will default build the full Remediation Script `CISBenchmarkScript.sh`.

```bash
$ ./Assemble.sh
```

If you want you can create a separate script by running the script with argument

```bash
$ ./Assemble.sh -s
```

You can find the build in `./Build/` directory

Upload this into your MDM Server. With Jamf Pro you can create a policy:
- Trigger *check-in*
- Frequency *once a day* 
- add the Script
- Include inventory update (to report result within Extension Attributes). 
- Scope to the target devices

### Assemble Jamf Pro Custom Schema JSON file

If you want you can create a JSON file for Jamf Pro by running the script with the argument

```bash
$ ./Assemble.sh -j
```

### Upload CIS Benchmark Settings Configuration Profile 
Configure a Configuration Profile, see example, and if you are using Jamf Pro, you can use the **[Jamf Pro Custom Schema.json](https://github.com/mvdbent/CIS-Script/blob/main/Jamf/Jamf%20Pro%20Custom%20Schema.json)** to configure the reporting, remediation and scoring. Scope the CIS Benchmark Settings Profile to the target devices.

### Configure CIS Configuration Profiles. 
Setup the needed Configuration Profiles for the CIS Benchmarks rules you scoring on with your MDM server or generate them with the **[CIS-macOS-Security](https://github.com/mvdbent/CIS-macOS-Security)** integrated with the macOS Security Compliance Project. Scope to the target devices.

### Extension Attributes [Jamf Pro Server](https://github.com/mvdbent/CIS-Script/tree/main/Jamf/EA)
Upload the Extension Attributes into your Jamf Pro Server.

### Upload_CISBenchmarkReport.sh Script
It is possible to upload the report to Jamf so that you can read it without requiring access to the computer. To do so, perform the following steps:
* Create an account used for the script
* Grant the account the following privileges:
    * Jamf Pro Server Objects > Computers: Create, Read, Update
    * Jamf Pro Server Objects > File Attachments: Create, Update, Delete
* Upload the script /Git/CIS-Script/Jamf/Upload_CISBenchmarkReport.sh as a script in Jamf
* Add this as a script to your existing CIS policy and use the priority "After" so that it runs second
* Ensure you add the credentials in Variable 4 using this to create the encoded value:
```bash
$ printf "username:password" | iconv -t ISO-8859-1 | base64 -i -
```
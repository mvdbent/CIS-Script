# CIS-Script
<img src="https://github.com/mvdbent/CIS-Script/blob/dev/Utils/CIS-Script.png" width="250">

_**Current state of the scripts are:** "This project is 'As is" please be free to give me any feedback_

![GitHub](https://img.shields.io/badge/macOS-11-success)
![GitHub](https://img.shields.io/github/license/mvdbent/CIS-Script)
<!-- ![GitHub](https://img.shields.io/github/v/release/mvdbent/CIS-Script) -->
<!-- ![GitHub](https://img.shields.io/github/downloads/mvdbent/CIS-Script/latest/total) -->
<!-- ![GitHub](https://img.shields.io/badge/macOS-10.15%2B-yellow) -->

<<<<<<< HEAD
## DESCRIPTION
This CIS Script is build to report and remediate based on the your organisation score.

## Info
While working with CIS Benchmarks (Remediation Scripts and/or Configuration Profiles) I felt this could be done better, faster and easier.
The guys from the [macOS Security Compliance Project](https://github.com/usnistgov/macos_security) did an amazing job automating the guidance and configuration profiles.

I created custom rules set for *[CIS Benchmark](https://downloads.cisecurity.org/#/)* to integrate with the macOS Security Compliance Project and published [CIS-macOS-Security](https://github.com/mvdbent/CIS-macOS-Security).

While working with **CIS Benchmark**, **Script** and **Configuration Profile**, I had the feeling there was missing a overview with compleet reporting, and there for build a read only CIS-Reporting script you can find [here](https://github.com/mvdbent/CIS-Reporting)

Ended up with seperate tools, creation of the **Documention**, **Configuration Profiles** and **Reporting**. However I still needed an extra script for remediation.

To resolve this I combined the reporting script with remediation with the option to enable remediation or not. 

For easy maintaining, the CIS-Script is built-in Fragments. There is a `Header.sh`, `Footer.sh`, `Version.sh` and an folder **OrgScore** filled with seperate `OrgScore*.sh`. This way it's easier to focus on a specifiek rule.

To assemble all the fragements together in a Script you can use standalone or via an MDM server (like Jamf Pro) you can use the `Assemble.sh` script. After assembling the Remediation Script, standalone it will preform a read only check and creates a full report. 

```bash
$ sudo ./CISBenchmarkScript.sh
```
*Location of the report `/Library/Security/Reports/`*

If you use the script via a MDM you can set the script to create a short or full report, and enable or disable remediation.

## Usage/Requirements
*The CIS-Script is tested on macOS Big Sur 11.*

* Test OrgScore*.sh
* Assembled Remediation Script
* Upload CIS Benchmark Settings Configuration Profile
* Configure CIS Configuration Profiles.
* Extension Attributes [Jamf Pro Server](https://github.com/mvdbent/CIS-Script/tree/main/Jamf/EA)


### Test OrgScore*.sh
For adjustments, you can test every OrgScore seperatly.

```bash
$ cd /Git/CIS-Script/Fragments/OrgScores
$ sudo ./OrgScore*.sh
```

### Assemble Remediation Script
The `Assemble.sh` will default build the full Remediation Script `CISBenchmarkScript.sh`.

```bash
$ ./Assemble.sh
```

If you want you can create seperate script by running the script with argument

```bash
$ ./Assemble.sh -s
```
you can find the build in `./Build/` folder

Upload this into your MDM Server. With Jamf Pro you can create a policy, Trigger *check-in* Frequency *once a day* add the Script, include inventory update (to report result within Extension Attributes). Scope to the target devices.

### Upload CIS Benchmark Settings Configuration Profile 
Configure an Configration Profile, see example, and if you using Jamf Pro, you can use the **[Jamf Pro Custom Schema.json](https://github.com/mvdbent/CIS-Script/blob/main/Jamf/Jamf%20Pro%20Custom%20Schema.json)** to configure the reporting and remediation and scoring. Scope the CIS Benchmark Settings Profile to the target devices.

### Configure CIS Configuration Profiles. 
Setup the needed Configuration Profiles for the CIS Benchmarks rules you scoring on with your MDM server or generated them with the **[CIS-macOS-Security](https://github.com/mvdbent/CIS-macOS-Security)** integrated with the macOS Security Compliance Project. Scope to the target devices.

### Extension Attributes [Jamf Pro Server](https://github.com/mvdbent/CIS-Script/tree/main/Jamf/EA)
Upload the Extension Atrributes into you Jamf Pro Server.
=======
| Legend |  |
| --- | --- |
| R | Report checked |
| S | Script Remediation checked |
## CheckList

|   OrgScore   	|   macOS 10.15  	|   macOS 11  	|   macOS 12	|
|:---:	|:---:	|:---:	|:---:	|:---:	|    
| OrgScore 1.1 | R | R | R | 
| OrgScore 1.2  	|     	|     	|     	|
| OrgScore 1.3  	|     	|     	|     	|
|   OrgScore 1.4  	|     	|     	|     	|
|   OrgScore 1.5  	|     	|     	|     	|
|   OrgScore 1.6  	|     	|     	|     	|
|   OrgScore 2.1.1  	|     	|     	|     	|
|   OrgScore 2.1.2  	|     	|     	|     	|
|   OrgScore 2.2.1  	|     	|     	|     	|
|   OrgScore 2.2.2  	|     	|     	|     	|
|   OrgScore 2.3.1  	|     	|     	|     	|
|   OrgScore 2.3.2  	|     	|     	|     	|
|   OrgScore 2.3.3  	|     	|     	|     	|
|   OrgScore 2.4.1  	|     	|     	|     	|
|   OrgScore 2.4.10  	|     	|     	|     	|
|   OrgScore 2.4.11  	|     	|     	|     	|
|   OrgScore 2.4.2  	|     	|     	|     	|
|   OrgScore 2.4.3  	|     	|     	|     	|
|   OrgScore 2.4.4  	|     	|     	|     	|
|   OrgScore 2.4.5  	|     	|     	|     	|
|   OrgScore 2.4.6  	|     	|     	|     	|
|   OrgScore 2.4.7  	|     	|     	|     	|
|   OrgScore 2.4.8  	|     	|     	|     	|
|   OrgScore 2.4.9  	|     	|     	|     	|
|   OrgScore 2.5.1.1  	|     	|     	|     	|
|   OrgScore 2.5.1.2  	|     	|     	|     	|
|   OrgScore 2.5.1.3  	|     	|     	|     	|
|   OrgScore 2.5.2.1  	|     	|     	|     	|
|   OrgScore 2.5.2.2  	|     	|     	|     	|
|   OrgScore 2.5.2.3  	|     	|     	|     	|
|   OrgScore 2.5.3  	|     	|     	|     	|
|   OrgScore 2.5.4  	|     	|     	|     	|
|   OrgScore 2.5.5  	|     	|     	|     	|
|   OrgScore 2.5.6  	|     	|     	|     	|
|   OrgScore 2.5.7  	|     	|     	|     	|
|   OrgScore 2.6.1  	|     	|     	|     	|
|   OrgScore 2.6.2  	|     	|     	|     	|
|   OrgScore 2.6.3  	|     	|     	|     	|
|   OrgScore 2.6.4  	|     	|     	|     	|
|   OrgScore 2.7.1  	|     	|     	|     	|
|   OrgScore 2.7.2  	|     	|     	|     	|
|   OrgScore 2.8  	|     	|     	|     	|
|   OrgScore 2.9  	|     	|     	|     	|
|   OrgScore 2.10  	|     	|     	|     	|
|   OrgScore 2.11  	|     	|     	|     	|
|   OrgScore 3.1  	|     	|     	|     	|
|   OrgScore 3.2  	|     	|     	|     	|
|   OrgScore 3.3  	|     	|     	|     	|
|   OrgScore 3.4  	|     	|     	|     	|
|   OrgScore 3.5  	|     	|     	|     	|
|   OrgScore 3.6  	|     	|     	|     	|
|   OrgScore 4.1  	|     	|     	|     	|
|   OrgScore 4.2  	|     	|     	|     	|
|   OrgScore 4.4  	|     	|     	|     	|
|   OrgScore 4.5  	|     	|     	|     	|
|   OrgScore 5.10  	|     	|     	|     	|
|   OrgScore 5.11  	|     	|     	|     	|
|   OrgScore 5.12  	|     	|     	|     	|
|   OrgScore 5.13  	|     	|     	|     	|
|   OrgScore 5.14  	|     	|     	|     	|
|   OrgScore 5.16  	|     	|     	|     	|
|   OrgScore 5.18  	|     	|     	|     	|
|   OrgScore 5.1.1  	|     	|     	|     	|
|   OrgScore 5.1.2  	|     	|     	|     	|
|   OrgScore 5.1.3  	|     	|     	|     	|
|   OrgScore 5.1.4  	|     	|     	|     	|
|   OrgScore 5.3  	|     	|     	|     	|
|   OrgScore 5.4  	|     	|     	|     	|
|   OrgScore 5.5  	|     	|     	|     	|
|   OrgScore 5.6  	|     	|     	|     	|
|   OrgScore 5.7  	|     	|     	|     	|
|   OrgScore 5.8  	|     	|     	|     	|
|   OrgScore 5.9  	|     	|     	|     	|
|   OrgScore 6.1.1  	|     	|     	|     	|
|   OrgScore 6.1.2  	|     	|     	|     	|
|   OrgScore 6.1.3  	|     	|     	|     	|
|   OrgScore 6.1.4  	|     	|     	|     	|
|   OrgScore 6.1.5  	|     	|     	|     	|
|   OrgScore 6.2  	|     	|     	|     	|
|   OrgScore 6.3  	|     	|     	|     	|
>>>>>>> 930736273dc9515002e3d79a2912d6cb37280319

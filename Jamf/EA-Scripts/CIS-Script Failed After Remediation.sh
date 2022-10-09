#!/bin/zsh
# shellcheck shell=bash

# CIS-Script Failed After Remediation

auditfile=/Library/Security/Reports/CISBenchmarkReport.csv
echo "<result>$(grep -c "Failed After Remediation" "$auditfile")</result>"
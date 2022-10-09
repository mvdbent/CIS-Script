#!/bin/zsh
# shellcheck shell=bash

# CIS-Script Not applicable

auditfile=/Library/Security/Reports/CISBenchmarkReport.csv
echo "<result>$(grep -c "Not applicable" "$auditfile")</result>"
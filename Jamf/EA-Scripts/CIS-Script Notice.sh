#!/bin/zsh
# shellcheck shell=bash

# CIS-Script Notice

auditfile=/Library/Security/Reports/CISBenchmarkReport.csv
echo "<result>$(grep -c "Notice" "$auditfile")</result>"
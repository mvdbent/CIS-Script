#!/bin/zsh
# shellcheck shell=bash

# CIS-Script Scored

auditfile=/Library/Security/Reports/CISBenchmarkReport.csv
echo "<result>$(grep -c "Scored" "$auditfile")</result>"
#!/bin/zsh

projectfolder=$(dirname "${0:A}")

# destination
endResult=${projectfolder}/CISBenchmarkRemediationReport.sh

# add shebang
echo "#!/bin/zsh" > ${endResult}

# add version and date
version=$(cat "${projectfolder}/Fragments/Version.sh")
versiondate=$(date +%F)
echo "VERSION=\"$version\"" >> ${endResult}
echo "VERSIONDATE=\"$versiondate\"" >> ${endResult}
echo >> ${endResult}

# add header
cat ${projectfolder}/Fragments/Header.sh >> ${endResult}

# loop over fragments
for filePath in ${projectfolder}/Fragments/OrgScores/OrgScore*.sh; do

    # fragment name
    fileName=$(basename ${filePath})
    echo "Add ${fileName} to script"

    # add script
    tail -n +6 ${filePath} >> ${endResult}
    echo >> ${endResult}

done

# add footer
cat ${projectfolder}/Fragments/Footer.sh >> ${endResult}

# make script executable
chmod +x ${endResult}

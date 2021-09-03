#!/bin/zsh

projectfolder=$(dirname "${0:A}")

# loop over fragments
for filePath in ${projectfolder}/Fragments/OrgScores/OrgScore*.sh; do

    # fragment name
    fileName=$(basename ${filePath})

    # destination
    endResult="${projectfolder}/Separate/${fileName}"

    # add shebang
    echo "#!/bin/zsh" > ${endResult}
    echo >> ${endResult}

    # add version and date
    version=$(cat "${projectfolder}/Fragments/Version.sh")
    versiondate=$(date +%F)
    echo "VERSION=\"$version\"" >> ${endResult}
    echo "VERSIONDATE=\"$versiondate\"" >> ${endResult}
    echo >> ${endResult}

    # add header
    cat ${projectfolder}/Fragments/Header.sh >> ${endResult}
    
    # add script
    tail -n +7 ${filePath} >> ${endResult}
    echo >> ${endResult}

    # add footer
    cat ${projectfolder}/Fragments/Footer.sh >> ${endResult}
    
    # make script executable
    chmod +x ${endResult}

    echo "${fileName} created"

done
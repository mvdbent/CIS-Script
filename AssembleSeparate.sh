#!/bin/zsh

projectfolder=$(dirname "${0:A}")

# loop over fragments
for filePath in ${projectfolder}/Fragments/OrgScore*.sh; do

    # fragment name
    fileName=$(basename ${filePath})

    # destination
    cisScript="${projectfolder}/Separate/${fileName}"

    # add shebang
    echo "#!/bin/zsh" > ${cisScript}
    echo >> ${cisScript}

    # add version and date
    version=$(cat "${projectfolder}/Fragments/Version.sh")
    versiondate=$(date +%F)
    echo "VERSION=\"$version\"" >> ${cisScript}
    echo "VERSIONDATE=\"$versiondate\"" >> ${cisScript}
    echo >> ${cisScript}

    # add header
    cat ${projectfolder}/Fragments/Header.sh >> ${cisScript}
    
    # add script
    tail -n +6 ${filePath} >> ${cisScript}
    echo >> ${cisScript}

    # add footer
    cat ${projectfolder}/Fragments/Footer.sh >> ${cisScript}
    
    # make script executable
    chmod +x ${cisScript}

    echo "${fileName} created"

done
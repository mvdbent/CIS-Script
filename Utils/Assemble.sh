#!/bin/zsh

script_dir=$(dirname ${0:A})
projectfolder=$(dirname $script_dir)

help () {
    echo
    echo "The following options are available:"
    echo 
    echo "  -j  --json      Builds Jamf Pro Custom Schema.json file"
    echo "  -s  --separate  Builds separate CIS Benchmark Script from the fragements"
    echo "  -h  --help      Displays this message or details on a specific verb"
    echo 
    echo "EXAMPLES"
    echo "  ./Assemble.sh"
    echo "      Builds CIS Benchmark Script from the fragements"
    echo 
    echo "  ./Assemble.sh -j"
    echo "      Builds Jamf Pro Custom Schema.json file"
    echo 
    echo "  ./Assemble.sh -s"
    echo "      Builds separate CIS Benchmark Script from the fragements"
    echo 
    exit
}

buildScript () {
    # destination
    endPath=${projectfolder}/Build
    mkdir -p ${endPath}
    endResult=${endPath}/CISBenchmarkScript.sh

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

    # sort the filenames numerically
    setopt NUMERIC_GLOB_SORT

    # loop over fragments
    for filePath in ${projectfolder}/Fragments/OrgScores/OrgScore*.sh; do

        # fragment name
        fileName=$(basename ${filePath})
        echo "Add ${fileName} to script"

        # add script
        tail -n +7 ${filePath} >> ${endResult}
        echo >> ${endResult}

    done

    # add footer
    cat ${projectfolder}/Fragments/Footer.sh >> ${endResult}

    # make script executable
    chmod +x ${endResult}
}

# build seperate Scripts
buildSeperateScript () {
    # loop over fragments
    for filePath in ${projectfolder}/Fragments/OrgScores/OrgScore*.sh; do

        # fragment name
        fileName=$(basename ${filePath})

        # destination
        endPath=${projectfolder}/Build/Scripts
        mkdir -p ${endPath}
        endResult="${endPath}/${fileName}"

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
}

# build Jamf Pro Custom Schema.json file
createJamfJSON () {
    # destination
    endResultJSON=${projectfolder}/Build/"Jamf Pro Custom Schema.json"

    # add header
        cat ${projectfolder}/Fragments/Header.json > ${endResultJSON}

    # loop over fragments
    for filePath in ${projectfolder}/Fragments/OrgScores/OrgScore*.sh; do

        # fragment name
        # fileName=$(basename ${filePath})

        # variables
        orgScore=$(awk -F '"' '/^orgScore=/ {print $2}' ${filePath})
        audit=$(awk -F '"' '/^audit=/ {print $2}' ${filePath})

        # add orgScores
        cat >> ${endResultJSON} << EOF
        "${orgScore}": {
            "type": "boolean",
            "title": "${audit}",
            "description": "This boolean is true or false.",
            "default": "false"
        },
EOF
    done

    # remove the last line to close the list
    sed -i '' -e '$ d' ${endResultJSON}
    
    # add closer
    echo "        }" >> ${endResultJSON}
    echo "    }" >> ${endResultJSON}
    echo "}" >> ${endResultJSON}

    echo "Jamf Pro Custom Schema.json created"
}

case $1 in 
    -s | --separate)
       buildSeperateScript
    ;;
    -h | --help)
        help
    ;;
    -j | --json)
        createJamfJSON
    ;;
    *)
        buildScript
    ;;
esac
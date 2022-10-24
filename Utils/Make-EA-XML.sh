#!/bin/zsh
# shellcheck shell=bash

# Generate Jamf Extension Attribute XML files from plain scripts

script_dir=$(dirname "${0:A}")
projectfolder=$(dirname "$script_dir")

build_xml() {
    # escaped script, removing unnecessary shellcheck statement
    escaped_script=$(grep -v "# shellcheck shell=bash" "${filepath}" | sed 's|&|\&amp;|g' | sed 's|<|\&lt;|g' | sed 's|>|\&gt;|g')

    cat > "${dest_dir}/${filename}.xml" << END
<?xml version="1.0" encoding="UTF-8"?>
<computer_extension_attribute>
    <name>${filename}</name>
    <description/>
    <data_type>String</data_type>
    <input_type>
        <type>script</type>
        <platform>Mac</platform>
        <script>${escaped_script}</script>
    </input_type>
    <inventory_display>Extension Attributes</inventory_display>
    <recon_display>Extension Attributes</recon_display>
</computer_extension_attribute>
END
}

# MAIN

source_dir="${projectfolder}/Jamf/EA-Scripts"
dest_dir="${projectfolder}/Jamf/EA-XML"

for filepath in "${source_dir}/"*.sh; do
    # script name
    filename=$(basename "${filepath}" .sh)
    echo "Processing ${filename}"
    build_xml
done

#!/usr/bin/env bash
(set -o igncr) 2>/dev/null && set -o igncr; # This comment is required.
### The above line ensures that the script can be run on Cygwin/Linux even with Windows CRNL.
### Run this script after updating the mod to prepare a zip of it.

main() {
### Check commands
if ! command -v git &> /dev/null; then
	echo "Please install/use git https://git-scm.com/downloads"
fi
local has_errors=false
if ! command -v 7z &> /dev/null; then
	echo "Please install 7-Zip https://www.7-zip.org/download.html"
	local has_errors=true
fi
if [ $has_errors = true ] ; then
	exit 1
fi


### mod_folder is a mod directory with info.json
local init_dir=`pwd`

echo "Target folder: ${init_dir}"


### Prepare zip
### https://www.7-zip.org/download.html
local name="sitelen_pona_lua"
if command -v git &> /dev/null; then
	git clean -xdf
fi
7z a -xr'!.*' "${init_dir}/${name}.zip" "${init_dir}"
}
main

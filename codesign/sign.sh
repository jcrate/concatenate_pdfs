#!/usr/bin/env bash

scriptDir="${BASH_SOURCE%/*}"
echo "script directory: ${scriptDir}"
echo "signing ${1}"

# make sure user specified path to binary
if [[ $# -lt  1 || ! -f $1 ]]
then
  echo "ERROR: no binary specified for signing"
  echo 1>&2 "Usage: $0 binary_to_sign"
  exit 127
fi

binaryPath=$1

if [[ ! -f "${scriptDir}/developer_id.env" ]]
then
  echo "ERROR: developer_id.env does not exist. Rename developer_id.env.example and specify your developer ID."
  exit 127
fi

dev_id="sourced from developer_id.env"
source "${scriptDir}/developer_id.env"
echo "sourced developer id: ${dev_id}"

echo "signing ${binaryPath}"
# clean up by removing file system extended attributes
xattr -cr "${binaryPath}"
  
  
entPath="${scriptDir}/signing.entitlements"
codesign --force --deep --verbose --options=runtime --entitlements ${entPath} --sign "${dev_id}" "${binaryPath}"
  
# check code-signing
echo "checking signing"
spctl -av "${binaryPath}"
codesign --verify -v "${binaryPath}"

# zip for notarization
echo "zipping for notarization"
zipPath="${binaryPath}.zip"
if [[ -f "${zipPath}" ]]
then
  rm "${zipPath}"
fi
ditto -c -k --sequesterRsrc "${binaryPath}" "${zipPath}"


echo "uploading for notarization with credentials ${notarytool_credentials}"
xc_output=$( \
  xcrun notarytool submit --wait ${notarytool_credentials} "${zipPath}"
)
echo "finished uploading"
echo "${xc_output}"

# stapling an executable doesn't work
# echo "stapling"
# xcrun stapler staple "${binaryPath}" -v
# rm "${zipPath}"
# ditto -c -k --sequesterRsrc --keepParent "${binaryPath}" "${zipPath}"
#
# echo "checking notarization"
# spctl -av "${binaryPath}"



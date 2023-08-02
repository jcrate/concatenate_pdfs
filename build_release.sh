#!/usr/bin/env bash

cd "${BASH_SOURCE%/*}" || exit

# cleanup
rm -rf .build
rm -rf ./built_product/
mkdir -p ./built_product

# build
swift build -c release --arch arm64 --arch x86_64

# check for built product
binaryPath=".build/apple/Products/Release/concatenate_pdfs"
if [[ ! -f ${binaryPath} ]]
then
  echo "ERROR: compiled binary not found at ${binaryPath}"
  exit 127
fi

# copy binary to built products
cp ${binaryPath} ./built_product/
binaryPath="./built_product/concatenate_pdfs"

# codesign
./codesign/sign.sh "${binaryPath}"


echo "Copy built product from ${binaryPath}"

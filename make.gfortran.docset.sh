#!/bin/bash
###############################################
# Usage:
#   ./make.gfortran.docset.sh [version]
#
# e.g.
#   ./make.gfortran.docset.sh 5.1.0
###############################################

set -euo pipefail

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

GFORTRAN_VERSION=$1
: ${GFORTRAN_VERSION:="5.1.0"}
CONTENTS_DIR=gfortran_${GFORTRAN_VERSION}.docset/Contents/
RES_DIR=${CONTENTS_DIR}/Resources/
DOC_DIR=${RES_DIR}/Documents/
HTML_FILE=gfortran-html.${GFORTRAN_VERSION}.tar.gz
FORTRAN_DOC_URL=https://gcc.gnu.org/onlinedocs/gcc-${GFORTRAN_VERSION}/gfortran-html.tar.gz

#
# Download gfortran manual
#
if [ ! -f "$HTML_FILE" ]; then
    echo "Download GNU Fortran $GFORTRAN_VERSION manual"
    wget ${FORTRAN_DOC_URL} -O ${HTML_FILE}
    if [ ! $? ]; then exit 1; fi
fi

#
# Uncompress document file
#
echo "Uncompress document file"
if [ -f "$HTML_FILE" ]; then
    mkdir -p ${DOC_DIR}
    tar xf ${HTML_FILE} -C $DOC_DIR --strip-components=1
    cp icon.png icon@2x.png ${CONTENTS_DIR}/../
else
    echo ${HTML_FILE} NOT exist!
    exit 1
fi

#
# Generate Info.plist file
#
echo "Generate Info.plist file"
tee ${CONTENTS_DIR}/Info.plist >/dev/null <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>dashIndexFilePath</key>
    <string>index.html</string>
    <key>CFBundleIdentifier</key>
    <string>gfortran</string>
    <key>CFBundleName</key>
    <string>GNU Fortran ${GFORTRAN_VERSION}</string>
    <key>DocSetPlatformFamily</key>
    <string>gfortran</string>
    <key>isDashDocset</key>
    <true/>
</dict>
</plist>
EOF

#
# Generate index database
#
echo "Generate index database"
"${SCRIPT_DIR}/generate_index.py" "${RES_DIR}" "${DOC_DIR}"

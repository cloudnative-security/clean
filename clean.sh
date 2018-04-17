#!/usr/bin/env bash

if [[ $(id -u) -ne 0 ]]; then
    echo "Must be root!"
    exit 1
fi

rm -rf /Library/Application\ Support/{Logic,GarageBand}
rm -rf /Applications/GarageBand.app

rm -rf /Applications/Microsoft\ Silverlight

rm -rf /Library/iTunes

rm -rf /Library/Desktop\ Pictures

rm -rf /Users/*/Photos/{Photo\ Booth\ Library,Photos\ Library}

# TODO: Optionally remove McAfee

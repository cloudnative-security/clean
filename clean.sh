#!/usr/bin/env bash

function yn {
    read -p "$1 [y/n] " reply
    if [[ $reply =~ ^[Yy] ]]; then
        return 0
    else
        return 1
    fi
}

if [[ $(id -u) -ne 0 ]]; then
    echo "Must be root!"
    exit 1
fi

user=$(stat -f "%Su" /dev/console) # Get user currently logged in (in GUI).

if yn "Remove musical files (such as GarageBand, Logic loops)?"; then
    rm -rf /Library/Application\ Support/{Logic,GarageBand}
    rm -rf /Applications/GarageBand.app
fi

if yn "Purge OS help files and documentation?"; then
    rm -rf /Library/Documentation
fi

if yn "Purge all Adobe products? (Careful!)"; then
    rm -rf /Applications/Adobe*
    rm -rf /Library/Application\ Support/Adobe
fi

if yn "Remove Dashboard widgets?"; then
    rm -rf /Library/Widgets
fi

if yn "Remove non-English local dictionaries?"; then
    if yn "Remove all local dictionaries?"; then
        rm -rf /Library/Dictionaries
    else
        find /Library/Dictionaries -type f ! -name '*Oxford*' -delete
    fi
fi

if yn "Remove Microsoft Silverlight?"; then
    rm -rf /Applications/Microsoft\ Silverlight
fi

if yn "Remove iTunes files?"; then
    rm -rf /Library/iTunes
fi

if yn "Purge factory desktop pictures?"; then
    rm -rf /Library/Desktop\ Pictures
fi

if yn "Remove Photo Booth library?"; then
    if yn "Dump Photo Booth library on desktop for you to sort out?"; then
        mv /Users/$user/Pictures/Photo\ Booth\ Library/Pictures /Users/$user/Desktop/photo_booth
    fi
    rm -rf /Users/$user/Pictures/{Photo\ Booth\ Library}
fi

if yn "Remove Photos library?"; then
    rm -rf /Users/$user/Pictures/Photos\ Library
fi

if yn "Remove Microsoft Auto Update and Error Reporter?"; then
    rm -rf /Library/Application\ Support/Microsoft
fi

if yn "Remove McAfee? (DON'T)"; then
    rm -rf /Applications/McAfee*
    rm -rf /Library/McAfee*
    rm -rf /Library/Application\ Support/McAfee*
    rm -rf /usr/local/McAfee
    rm -rf /Library/Startup\ Items/cma
fi

if yn "Remove Default Account User Pictures?"; then
    rm -rf /Library/User\ Pictures
fi

#!/usr/bin/env bash

function yn {
    read -p "$1 [y/n] " reply
    if [[ $reply =~ ^[Yy] ]]; then
        return 0
    else
        return 1
    fi
}

function is_empty {
    return [[ -z "$(ls $1)" ]]
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

yn "Purge OS help files and documentation?" && rm -rf /Library/Documentation
yn "Purge all Adobe products? (Careful!)" && (rm -rf /Applications/Adobe*; rm -rf /Library/Application\ Support/Adobe)
yn "Remove Dashboard widgets?" && rm -rf /Library/Widgets

if yn "Remove non-English local dictionaries?"; then
    if yn "Remove all local dictionaries?"; then
        rm -rf /Library/Dictionaries
    else
        find /Library/Dictionaries -type f ! -name 'Apple Dictionary.dictionary' -delete
    fi
fi

yn "Remove Microsoft Silverlight?" && rm -rf /Applications/Microsoft\ Silverlight
yn "Remove iTunes files?" && rm -rf /Library/iTunes
yn "Remove factory desktop pictures?" && rm -rf /Library/Desktop\ Pictures
yn "Remove Default Account User Pictures?" && rm -rf /Library/User\ Pictures
yn "Remove Screen Savers?" && rm -rf /Library/Screen\ Savers

if yn "Remove Photo Booth library?"; then
    if yn "Dump Photo Booth library on desktop for you to sort out?"; then
        mv /Users/$user/Pictures/Photo\ Booth\ Library/Pictures /Users/$user/Desktop/photo_booth
    fi
    rm -rf /Users/$user/Pictures/Photo\ Booth\ Library
fi

if yn "Remove Photos library and data?"; then
    rm -rf /Users/$user/Pictures/Photos\ Library
    rm -rf /Users/$user/Library/Containers/com.apple.Photos*
fi
yn "Remove Microsoft Auto Update and Error Reporter?" && rm -rf /Library/Application\ Support/Microsoft
yn "Remove synthesized voices?" && rm -rf /System/Library/Speech
yn "Remove BBEdit?" && rm -rf /Applications/BBEdit.app

yn "Entering danger zone! Remaining objects should generally not be removed. Exit?" && exit

yn "Temporarily disable WiFi?" && networksetup -setairportpower airport off >/dev/null

if yn "Remove VitalSource Bookshelf and installed textbooks? (Don't do this during the year.)"; then
    rm -rf /Applications/VitalSource\ Bookshelf.app
    rm -rf /Users/$user/Books/VitalSource\ Bookshelf
    is_empty /User/$user/Books && rm -rf /Users/$user/Books
fi

if yn "Remove McAfee?"; then
    rm -rf /Applications/McAfee*
    rm -rf /Library/McAfee*
    rm -rf /Library/Application\ Support/McAfee*
    rm -rf /usr/local/McAfee
    rm -rf /Library/Startup\ Items/cma
fi

if yn "Remove Barracuda?"; then
    rm -rf /Library/Application Support/Barracuda\ WSA
    rm -rf /Library/Extensions/BarracudaWSA.kext
    rm -rf /Library/Logs/BarracudaWSA*
fi

if yn "Remove JAMF?"; then
    for _ in {1..8}; do killall jamf jamfAgent 2>/dev/null; done
    rm -rf /Library/Application\ Support/JAMF
fi

networksetup -setairportpower airport on >/dev/null

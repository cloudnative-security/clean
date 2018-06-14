#!/usr/bin/env bash

function yn {
    read -p "$1 [y/n] " reply
    [[ $reply =~ ^[Yy] ]]
}

function is_empty {
    [[ -z "$(ls "$1")" ]]
}

function userdel {
    dscl localhost delete /Local/Default/Users/$1
    rm -rf /Users/$1
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
    if ! is_empty /Users/$user/Pictures/Photo\ Booth\ Library/Pictures && yn "Dump Photo Booth library on desktop for you to sort out?"; then
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

if yn "Clear crash reports and logs?"; then
    rm -rf /Library/Application\ Support/CrashReporter/*
    rm -rf /Library/Logs/*
    rm -rf /private/var/log/*
fi

if yn "Are you comfortable with removing important security systems?"; then
    yn "Temporarily disable WiFi?" && networksetup -setairportpower airport off >/dev/null

    if yn "Remove Microsoft Office?"; then
        rm -rf /Applications/Microsoft\ Office\ 2011 \
               /Users/$user/Library/Containers/com.microsoft.* \
               /Users/$user/Library/Group\ Containers/*.ms
    fi

    if yn "Remove VitalSource Bookshelf and installed textbooks?"; then
        rm -rf /Applications/VitalSource\ Bookshelf.app \
               /Users/$user/Books/{VitalSource\ Bookshelf,Icon*} \
               /Users/Shared/Books/{VitalSource\ Bookshelf,Icon*}
        is_empty /Users/$user/Books && rm -rf /Users/$user/Books
        is_empty /Users/Shared/Books && rm -rf /Users/Shared/Books
    fi

    if yn "Remove Logger Pro?"; then
        rm -rf /Applications/Logger\ Pro\ 3/ \
               /Library/Application\ Support/National\ Instruments \
               /Users/$user/Library/Application\ Support/Logger\ Pro
    fi

    if yn "Remove Lockdown Browser?"; then
        rm -rf /Applications/Lockdown\ Browser.app \
               /private/var/db/receipts/com.respondus.LockdownBrowser* \
               /Users/*/Library/Application\ Support/com.apple.sharedfilelist/com.apple.LSSharedFileList.ApplicationRecentDocuments/com.respondus.lockdownbrowser.sfl \
               /Users/$user/Library/Application\ Support/Respondus\ LockDown\ Browser
    fi

    if yn "Remove McAfee?"; then
        rm -rf /Applications/McAfee* \
               /Library/McAfee* \
               /Library/Application\ Support/McAfee* \
               /usr/local/McAfee \
               /Library/Startup\ Items/cma \
               /Quarantine
    fi

    if yn "Disable ARD?"; then
        # To totally remove (requires SIP disabled):
        #rm -rf /System/Library/CoreServices/RemoteManagement/ARDAgent.app
        /System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart -deactivate -configure -access -off
    fi

    if yn "Remove Managed Prefences?"; then
        rm -rf /Library/Managed\ Preferences
    fi

    if yn "Remove Barracuda?"; then
        # You can find the actual uninstall script here:
        # /Library/Application Support/Barracuda WSA/WSA Uninstaller.app/Contents/Resources/uninstall.sh
        # I don't trust it though, so let's do the dirty work ourselves
        killall wsa_proxy
        rm -rf /Library/Application\ Support/Barracuda\ WSA \
               /Library/Extensions/BarracudaWSA.kext \
               /Library/Logs/BarracudaWSA* \
               /Library/PreferencePanes/Barracuda\ WSA* \
               /Library/LaunchDaemons/com.barracuda*
        echo "Barracuda restrictions will disappear after restart."
        # TODO: Disable without restart
    fi

    if yn "Remove JAMF?"; then
        for _ in {1..8}; do killall jamf jamfAgent 2>/dev/null; done
        rm -rf /usr/local/bin/jamf* \
               /Library/LaunchAgents/com.jamfsoftware* /Library/LaunchDaemons/com.jamfsoftware* \
               /private/var/db/receipts/com.jamfsoftware* \
               /private/var/root/Library/{Caches,Cookies,Preferences}/com.jamfsoftware* \
               /private/var/run/jamf \
               /Users/$user/Library/Application\ Support/com.apple.sharedfilelist/*/com.jamfsoftware* \
               /Users/$user/Library/Preferences/com.jamfsoftware* \
               /Library/Preferences/com.jamfsoftware* \
               /Users/boesene/Library/Logs/JAMF \
               /usr/local/jamf \
               /Library/Application\ Support/JAMF
    fi

    if yn "Remove FCCPS accounts?"; then
        userdel gmtest
        userdel remotedesktop
        userdel support
        userdel admin
    fi

    networksetup -setairportpower airport on >/dev/null
fi

# Each of these is listed as a directory protected by SIP
# (list present at /System/Library/Sandbox/rootless.conf).
# Other users of this script are encouraged to (un)comment
# applications as desired to fit their needs.
sip_apps=(
    /Applications/App\ Store.app
    /Applications/Automator.app
    #/Applications/Calculator.app
    /Applications/Calendar.app
    /Applications/Chess.app
    /Applications/Contacts.app
    /Applications/Dashboard.app
    #/Applications/Dictionary.app
    /Applications/DVD\ Player.app
    /Applications/FaceTime.app
    #/Applications/Font\ Book.app
    /Applications/Game\ Center.app
    /Applications/Image\ Capture.app
    /Applications/Launchpad.app
    /Applications/Mail.app
    /Applications/Maps.app
    /Applications/Messages.app
    #/Applications/Mission\ Control.app
    /Applications/Notes.app
    #/Applications/Photo\ Booth.app
    /Applications/Photos.app
    #/Applications/Preview.app
    #/Applications/QuickTime\ Player.app
    /Applications/Reminders.app
    #/Applications/Safari.app
    /Applications/Stickies.app
    #/Applications/System\ Preferences.app
    /Applications/TextEdit.app
    /Applications/Time\ Machine.app
    #/Applications/Utilities/Activity\ Monitor.app
    /Applications/Utilities/AirPort\ Utility.app
    /Applications/Utilities/Audio\ MIDI\ Setup.app
    /Applications/Utilities/Bluetooth\ File\ Exchange.app
    /Applications/Utilities/Boot\ Camp\ Assistant.app
    /Applications/Utilities/ColorSync\ Utility.app
    /Applications/Utilities/Console.app
    /Applications/Utilities/Digital\ Color\ Meter.app
    #/Applications/Utilities/Disk\ Utility.app
    /Applications/Utilities/Feedback\ Assistant.app
    # TODO: Unsure if this is required to take screenshots conventionally.
    #/Applications/Utilities/Grab.app
    /Applications/Utilities/Grapher.app
    #/Applications/Utilities/Keychain\ Access.app
    /Applications/Utilities/Migration\ Assistant.app
    #/Applications/Utilities/Script\ Editor.app
    /Applications/Utilities/System\ Information.app
    #/Applications/Utilities/Terminal.app
    /Applications/Utilities/VoiceOver\ Utility.app

    # Apple Remote Desktop Agent: special, but annoying
    # Disabled above, but we can't remove it with SIP on
    /System/Library/CoreServices/RemoteManagement/ARDAgent.app
)
if csrutil status | grep --quiet "enabled"; then
    echo "SIP enabled, skipping clearout of /Applications."
else
    for app in "${sip_apps[@]}"; do
        yn "Delete $app?" && rm -rf $app
    done
fi

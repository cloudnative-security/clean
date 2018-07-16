#!/usr/bin/env bash

logfile="/tmp/clean_$(date +%s).log"
echo > $logfile <<< "-- Running $1 on $(date). --"

function yn {
    read -p "$1 [y/n] " reply
    [[ $reply =~ ^[Yy] ]]
}

function is_empty {
    [[ -z "$(ls "$1")" ]]
}

function delete {
    rm -rfv $@ >> $logfile
}

function userdel {
    if id -u "$1" >/dev/null 2>&1; then
        dscl localhost delete /Local/Default/Users/$1
        delete /Users/$1
    else
        echo "User '$1' does not exist, skipping removal."
    fi
}

if [[ $(id -u) -ne 0 ]]; then
    echo "Must be root!"
    exit 1
fi

user=$(stat -f "%Su" /dev/console) # Get user currently logged in (in GUI).

if yn "Remove musical files (such as GarageBand, Logic loops)?"; then
    delete /Library/Application\ Support/{Logic,GarageBand}
    delete /Applications/GarageBand.app
fi

yn "Purge OS help files and documentation?" && delete /Library/Documentation
yn "Purge all Adobe products? (Careful!)" && (delete /Applications/Adobe* /Library/Application\ Support/Adobe)
yn "Remove Dashboard widgets?" && delete /Library/Widgets

if yn "Remove non-English local dictionaries?"; then
    if yn "Remove all local dictionaries?"; then
        delete /Library/Dictionaries
    else
        find /Library/Dictionaries -type f ! -name 'Apple Dictionary.dictionary' -delete
    fi
fi

yn "Remove Microsoft Silverlight?" && delete /Applications/Microsoft\ Silverlight
yn "Remove iTunes files?" && delete /Library/iTunes /Library/Frameworks/iTunesLibrary.framework
yn "Remove factory desktop pictures?" && delete /Library/Desktop\ Pictures
yn "Remove Default Account User Pictures?" && delete /Library/User\ Pictures
yn "Remove Automator files?" && delete /Library/Automator
yn "Remove Screen Savers?" && delete /Library/Screen\ Savers
yn "Remove Messages files?" && delete /Library/Messages
# Also of interest:
#   /Library/Caches

if yn "Remove Photo Booth library?"; then
    if ! is_empty /Users/$user/Pictures/Photo\ Booth\ Library/Pictures && yn "Dump Photo Booth library on desktop for you to sort out?"; then
        mv /Users/$user/Pictures/Photo\ Booth\ Library/Pictures /Users/$user/Desktop/photo_booth
    fi
    delete /Users/$user/Pictures/Photo\ Booth\ Library
fi

if yn "Remove Photos library and data?"; then
    delete /Users/$user/Pictures/Photos\ Library
    delete /Users/$user/Library/Containers/com.apple.Photos*
fi
yn "Remove Microsoft Auto Update and Error Reporter?" && delete /Library/Application\ Support/Microsoft
yn "Remove synthesized voices?" && delete /System/Library/Speech
yn "Remove BBEdit?" && delete /Applications/BBEdit.app

if yn "Clear crash reports, saved state, and logs?"; then
    delete /Library/Application\ Support/CrashReporter/*
    delete /Library/Logs/*
    delete /var/log/* /private/var/log/*
    delete /Users/$user/Library/Saved\ Application\ State
fi

if yn "Are you comfortable with removing important security systems?"; then
    yn "Temporarily disable WiFi?" && networksetup -setairportpower airport off >/dev/null

    if yn "Remove Microsoft Office?"; then
        delete /Applications/Microsoft\ Office\ 2011 \
               /Users/$user/Library/Containers/com.microsoft.* \
               /Users/$user/Library/Group\ Containers/*.ms \
               /Users/$user/Preferences/com.microsoft* \
               /Library/Preferences/com.microsoft*
    fi

    if yn "Remove VitalSource Bookshelf and installed textbooks?"; then
        delete /Applications/VitalSource\ Bookshelf.app \
               /Users/$user/Books/{VitalSource\ Bookshelf,Icon*} \
               /Users/Shared/Books/{VitalSource\ Bookshelf,Icon*}
        is_empty /Users/$user/Books && delete /Users/$user/Books
        is_empty /Users/Shared/Books && delete /Users/Shared/Books
    fi

    if yn "Remove Logger Pro?"; then
        delete /Applications/Logger\ Pro\ 3/ \
               /Library/Application\ Support/National\ Instruments \
               /Users/$user/Library/Application\ Support/Logger\ Pro
    fi

    if yn "Remove Lockdown Browser?"; then
        delete /Applications/Lockdown\ Browser.app \
               /private/var/db/receipts/com.respondus.LockdownBrowser* \
               /Users/*/Library/Application\ Support/com.apple.sharedfilelist/com.apple.LSSharedFileList.ApplicationRecentDocuments/com.respondus.lockdownbrowser.sfl \
               /Users/$user/Library/Application\ Support/Respondus\ LockDown\ Browser
    fi

    if yn "Remove McAfee?"; then
        delete /Applications/McAfee* \
               /Library/McAfee* \
               /Library/Application\ Support/McAfee* \
               /usr/local/McAfee \
               /Library/Startup\ Items/cma \
               /Library/LaunchDaemons/com.mcafee* \
               /Library/LaunchAgents/com.mcafee* \
               /Library/Frameworks/{VirusScanPreferences,AVEngine}.framework \
               /Quarantine
    fi

    if yn "Disable ARD?"; then
        # To totally remove (requires SIP disabled):
        #delete /System/Library/CoreServices/RemoteManagement/ARDAgent.app
        /System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart -deactivate -configure -access -off
    fi

    if yn "Leave Active Directory?"; then
        # dsconfigad requests a username and password of the directory admin to leave the active directory.
        # Hilariously, however, it will actually accept ANY username and password. The username you give doesn't even
        # have to be an admin, or even a real user on the domain. If you're root, it doesn't really care.
        # The only thing that won't happen is removal from the directory on admin's side of things.
        # But that doesn't really matter.
        # derflounder.wordpress.com/2013/10/09/force-unbinding-with-dsconfigad-without-using-an-active-directory-admin-account
        dsconfigad -remove -force -u "user" -p "password"
    fi

    if yn "Remove Managed Preferences?"; then
        delete /Library/Managed\ Preferences
        dscl . -delete /Computers
        dscl . -delete /Users/$user dsAttrTypeStandard:MCXSettings
        # Prevent the directory from being recreated; it shouldn't be
        ln -s /dev/null /Library/Managed\ Preferences
    fi

    if yn "Remove Barracuda?"; then
        # You can find the actual uninstall script here:
        # /Library/Application Support/Barracuda WSA/WSA Uninstaller.app/Contents/Resources/uninstall.sh
        # I don't trust it though, so let's do the dirty work ourselves
        killall wsa_proxy
        delete /Library/Application\ Support/Barracuda\ WSA \
               /Library/Extensions/BarracudaWSA.kext \
               /Library/Logs/BarracudaWSA* \
               /Library/PreferencePanes/Barracuda\ WSA* \
               /Library/LaunchDaemons/com.barracuda*
        echo "Barracuda restrictions will disappear after restart."
        # TODO: Disable without restart
    fi

    if yn "Remove JAMF?"; then
        for _ in {1..8}; do killall jamf jamfAgent 2>/dev/null; done
        delete /usr/local/bin/jamf* \
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
        yn "Delete $app?" && delete $app
    done
fi

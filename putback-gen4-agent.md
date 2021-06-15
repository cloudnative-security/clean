# put back iboss

sudo mv /Applications/Utilities/iboss.app/gen4agent/gen4agent-macos.bak /Applications/Utilities/iboss.app/gen4agent/gen4agent-macos 

# re run iboss
sudo /Applications/Utilities/iboss.app/gen4agent/gen4agent-macos -d

# change your proxy settings to (usually automatic)
in the browser http://127.0.0.1:8000/proxy.pac

# remove iboss
sudo pkill gen4agent
sudo mv /Applications/Utilities/iboss.app/gen4agent/gen4agent-macos /Applications/Utilities/iboss.app/gen4agent/gen4agent-macos.bak

This is required for okta integration though so it will stop your okta from running
and all application that requires okta for sso

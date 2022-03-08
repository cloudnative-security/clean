# put back iboss

`sudo mv /Applications/Utilities/iboss.app/gen4agent/gen4agent-macos.bak /Applications/Utilities/iboss.app/gen4agent/gen4agent-macos `

# re run iboss
`sudo /Applications/Utilities/iboss.app/gen4agent/gen4agent-macos -d`

# change your proxy settings to (usually automatic)
in the browser http://127.0.0.1:8000/proxy.pac

# remove iboss
```
sudo pkill gen4agent
sudo mv /Applications/Utilities/iboss.app/gen4agent/gen4agent-macos /Applications/Utilities/iboss.app/gen4agent/gen4agent-macos.bak
```

**Remove Proxy Setting in mac**
```
Wifi -> network preference -> advanced -> proxies -> toggle automatic proxy configuration
```
to add this back copy paste http://127.0.0.1:8000/proxy.pac and toggle it on

![Screenshot 2022-03-08 at 11 50 38](https://user-images.githubusercontent.com/13744098/157234006-92f18f0d-7bab-45df-a650-b1b340ebd85d.png)



This is required for okta integration though so it will stop your okta from running
and all application that requires okta for sso

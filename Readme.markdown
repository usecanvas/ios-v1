# Canvas for iOS

Canvas client for iOS.


## Building

1. Clone the code.

        $ git clone --recursive https://github.com/usecanvas/ios
        $ cd ios

2. You also need [Carthage](https://github.com/carthage/carthage). You can install with `brew install carthage`. Once you have Carthage, run the following:

        $ rake bootstrap

3. Open in Xcode 7.3

4. Click ▶️

If you have trouble building, try selecting *Clean* from the *Product* menu in the menu bar. If you are still having trouble, ask @soffes in Slack.


## Running

By default, the app will use the staging services. You can change this in `Configuration.swift` at the bottom.


## Installing on Your Device

1. Open *Preferences* in Xcode
2. Choose the *Accounts* tab
3. Click the plus button in the bottom left and choose *Add Apple ID…*
4. Sign in with your Apple ID. If you don't already have an Apple Developer account, you'll need to [create a free one](https://developer.apple.com/membercenter/).
5. Click *View Details…*
6. Click the button in the *Action* column next to *iOS Development*.
7. Close Preferences
8. Connect your device to your computer with USB
9. In the drop down in the top left next to the stop button, be sure *Canvas* is selected on the left half of the drop down and your device is selected on the right half. If your device isn't showing up, click *Window* in Xcode's menu bar, then *Devices*, choose your device, and click *Use for Development*.
10. Click ▶️ to run on your device. You may be asked to fix a provisioning issue. Click the fix button, wait a few seconds, close the dialog and try clicking ▶️ again.

If you have trouble running your device, ask @soffes for help in Slack.

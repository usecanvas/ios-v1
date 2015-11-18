# Canvas for iOS

Canvas client for iOS.


## Building

1. Clone the code.

        $ git clone https://github.com/usecanvas/canvas-ios && cd canvas-ios

2. Get the dependencies with [Carthage](https://github.com/carthage/carthage). (You can install Carthage with `brew install carthage`. Version 0.10 or higher is required.)

        $ carthage checkout --no-use-binaries

2. Open in Xcode 7 (or higher)

3. Click ▶️


## Running on Your Device

1. Open *Preferences* in Xcode
2. Choose the *Accounts* tab
3. Click the plus button in the bottom left and choose *Add Apple ID…*
4. Sign in with your Apple ID. If you don't already have an Apple Developer account, you'll need to [create a free one](https://developer.apple.com/membercenter/).
5. Close Preferences
6. Connect your device to your computer with USB
7. In the drop down in the top left next to the stop button, be sure *Canvas* is selected on the left half of the drop down and your device is selected on the right half. If your device isn't showing up, click *Window* in Xcode's menu bar, then *Devices*, choose your device, and click *Use for Development*.
8. Click ▶️ to run on your device. You may be asked to fix a provisioning issue. Click the fix button, wait a few seconds, close the dialog and try clicking ▶️ again.

If you have trouble running your device, ask @soffes for help in Slack.

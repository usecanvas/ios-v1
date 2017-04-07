# Canvas for iOS

Canvas client for iOS V1.

*Note:* This app was designed to work against V1 of Canvas, which is not released. There is no iOS client for V2. This repo is open sourced for reference only.


## Building

You will need [Xcode](https://itunes.apple.com/app/xcode/id497799835) 7.3.1 and [Carthage](https://github.com/carthage/carthage) 0.17.2 to build Canvas for iOS. You should ensure you have Xcode installed before beginning since that can take quite awhile. Be sure to open it at least once after downloading it.

1. Clone the code.

        $ git clone https://github.com/usecanvas/ios-v1
        $ cd ios-v1

2. Now, simply run the following command:

        $ rake bootstrap

    This will walk you through setting up everything you need to build Canvas for iOS.

3. Open `Canvas.xcodeproj` and click ▶️

If you have trouble building, quit Xcode, run `rake clean bootstrap`, and open Xcode again. If you are still having trouble, ask @soffes in Slack.


## Running

By default, the app will use the production services. You can change this in `Configuration.swift` at the bottom.

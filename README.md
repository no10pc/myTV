#myTV

myTV is an open source live tv app with robust and professional features.
This is a fully realized Radio App Created by [Matthew Fecher](http://matthewfecher.com)

![alt text](http://83colors.com/myTV_CAPS.png "myTV")

##Video
View this [**GETTING STARTED VIDEO**](https://youtu.be/m7jiajCHFvc).
It's short & sweet to give you a quick overview.  
Give it a quick watch.

##Features

- Loads and parses metadata (Logo and Channels)
- Displays TV Program Guide
- Ability to update playlist from server or locally. (Update stations anytime without resubmitting to app store!)
- Custom views optimized for iPhone 4s, 5, 6 and 6+ for backwards compatibility
- Compiles with Xcode 7 & Swift 2.0
- Supports local or hosted station images
- "About" page with ability to send email & visit website
- Uses industry standard SwiftyJSON library for easy JSON manipulation
- Pull to Refresh Stations

##Important Notes

- Volume slider does not work in Simulator, only in device. This appears to be an Xcode issue.
- Radio stations in demo are for demonstration purposes only. 
- For a production product, you may want to swap out the MPMoviePlayerController for a more robust streaming library/SDK (with stream stitching, interruption handling, etc).
- Uses Meng To's [Spring](https://github.com/MengTo/Spring) library for animation, making it easy experiment with different UI/UX animations
- SwiftyJSON & Spring are included in the repo to get you up & running quickly. It's on the roadmap to utilize CocoaPods in the future. 

##Credits
*Created by [Mustafa Sahin](http://83colors.com), Facebook: [@msahin](http://facebook.com/distinguish)*   

##Requirements

- iOS 8.0+ / Mac OS X 10.9+
- Xcode 7

##Setup

The "myTV-Settings.swift" file contains some project settings to get you started. Please enter your own LastFM Key.  
Watch this [Getting Started Video](https://youtu.be/) to get up & running quickly.

##Integration

Includes full Xcode Project to jumpstart development.

##Channels

Includes an example "stations.json" file. You may upload the JSON file to a server, so that you can update the stations in the app without resubmitting to the app store. The following fields are supported in the app:

- **name**: The name of the station as you want it displayed (e.g. "Sub Pop Radio")

- **streamURL**: The url of the actual stream

- **imageURL**: Station image url. Station images in demo are 350x206. Image can be local or hosted. Leave out the "http" to use a local image (You can use either: "station-subpop" or "http://myurl.com/images/station-subpop.jpg")

- **desc**: Short 2 or 3 word description of the station as you want it displayed (e.g. "Outlaw Country")

- **longDesc**: Long description of the station to be used on the "info screen". This is optional.

##Contributions

Contributions are very welcome. Please create a separate branch (e.g. features/3dtouch). Please do not commit on master.

##Streaming Libraries

- You can use this Swift code as a front-end for a more robust streaming backend.
- If you test it with a library, let me know!

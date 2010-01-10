# xBlip

xBlip is a native iPhone client for [blip.pl](http://blip.pl), Polish microblogging service. Currently in alpha stage
(which means, if anything doesn't work, looks like shit, doesn't have essential features, or explodes when you touch it
- don't complain... :).

The ObjectiveBlip directory contains the backend code that handles the connection to Blip API. It's a separate
subproject, available at [http://github.com/psionides/ObjectiveBlip](http://github.com/psionides/ObjectiveBlip), and you
can use it to create your own Blip clients in ObjectiveC/Cocoa if you want.

## Requirements

To install and run in a simulator, you need:

* a Mac
* XCode with newest (stable) iPhone SDK (i.e. not 3.0. It may work with 3.0, but I haven't tried.)

To install and run on an iPhone, you need additionally:

* an iPhone (seriously!)
* development certificates from Apple's iPhone Developer Program (100$ :( )

## Status

What's done:

* logging in, remembering login&password
* dashboard (list of recent messages, public and private)
* sending simple messages (without photos)

Plans for future:

* various look&feel improvements
* ObjectiveBlip refactoring, to make it communicate using notifications
* sending images
* bliposphere (feed of all users' messages)
* tag view (messages tagged with a specific tag)
* user info

## Screenshots

<a href="http://psionides.github.com/xblip/xblip_screen_login_24.05.2009.png"><img src="http://psionides.github.com/xblip/xblip_screen_login_24.05.2009.png" width="225" /></a> <a href="http://psionides.github.com/xblip/xblip_screen_dashboard_24.05.2009.png"><img src="http://psionides.github.com/xblip/xblip_screen_dashboard_24.05.2009.png" width="225" /></a>

## License

Copyright by Jakub Suder (Psionides) <jakub.suder at gmail.com>. Both the main project and the backend subproject are
licensed under MIT license.
Includes open source libraries NSData+MBBase64 by MiloBird, and BSJSONAdditions by Blake Seely.

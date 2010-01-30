# xBlip

xBlip is a native iPhone client for [blip.pl](http://blip.pl), Polish microblogging service.

The project is currently in early alpha stage and it will probably stay that way. Right now it can only log in,
display dashboard (and update it every 10 seconds) and let you send plain text messages, and that's it. I've started the
project last year (2009), when there was no Blip client for iPhone, but right now there's several of them, so I kind of
lost motivation. I'm leaving the project here as an example of using the iPhone SDK, maybe it will help someone...

The ObjectiveBlip directory contains the backend code that handles the connection to Blip API. It's a separate
subproject, available at [http://github.com/psionides/ObjectiveBlip](http://github.com/psionides/ObjectiveBlip), and you
can use it to create your own Blip clients in ObjectiveC/Cocoa if you want.

## Requirements

To install and run in a simulator, you need:

* a Mac
* Xcode with iPhone SDK 3.0 or later

To install and run on an iPhone, you need additionally:

* an iPhone (seriously!)
* development certificates from Apple's iPhone Developer Program (100$ :( per year :( )

## Screenshots

<a href="http://psionides.github.com/xblip/xblip_screen_login_24.05.2009.png"><img src="http://psionides.github.com/xblip/xblip_screen_login_24.05.2009.png" width="225" /></a> <a href="http://psionides.github.com/xblip/xblip_screen_dashboard_24.05.2009.png"><img src="http://psionides.github.com/xblip/xblip_screen_dashboard_24.05.2009.png" width="225" /></a>

## License

Copyright by Jakub Suder (Psionides) <jakub.suder at gmail.com>. Both the main project and the backend subproject are
licensed under MIT license.
Includes open source libraries BSJSONAdditions by Blake Seely and ASIHTTPRequest by Ben Copsey.

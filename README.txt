xBlip
-----

xBlip is a native iPhone client for blip.pl, Polish microblogging service. Currently in alpha stage (which means, if
anything doesn't work, looks like shit, doesn't have essential features, or explodes when you touch it - that's
intended).

The ObjectiveBlip directory contains the backend code that handles the connection to Blip API. It's considered a
separate subproject; you can use it to create your own Blip clients in ObjectiveC/Cocoa if you want.

Note: to install and run in a simulator, you need:
* a Mac
* XCode with newest iPhone SDK

To install and run on an iPhone, you need additionally:
* an iPhone (seriously!)
* development certificates from Apple's iPhone Developer Program

-----

Copyright by Jakub Suder (Psionides) <jakub.suder@gmail.com>. Licensed under MIT license.
Includes open source libraries NSData+MBBase64 by MiloBird, and BSJSONAdditions by Blake Seely.

# ObjectiveBlip

ObjectiveBlip is a Cocoa library that lets you connect to [blip.pl](http://blip.pl), Polish microblogging service,
via its REST API. It was extracted from [xBlip](http://github.com/psionides/xblip) project (iPhone client for Blip).
You can use it to create your own Blip clients in ObjectiveC/Cocoa if you want. It's pretty simple at the moment though,
so don't expect much...

## Setup instructions

* add a ObjectiveBlip directory to your project
* copy Classes, Lib and Constants.h from the ObjectiveBlip source tree to that directory
* create a new group "ObjectiveBlip" in your Xcode project; set its path to ObjectiveBlip directory (context menu -> "Get Info" -> path)
* add -> existing files -> select everything inside ObjectiveBlip directory
* add CFNetwork, SystemConfiguration and zlib (libz.1.2.3) frameworks to your project (follow the [ASIHTTPRequest documentation](http://allseeing-i.com/ASIHTTPRequest/Setup-instructions)

## Usage instructions

TODO...

## License

Copyright by Jakub Suder (Psionides) <jakub.suder at gmail.com>. Licensed under MIT license.
Includes open source libraries NSData+MBBase64 by MiloBird, and BSJSONAdditions by Blake Seely, and ASIHTTPRequest by Ben Copsey.

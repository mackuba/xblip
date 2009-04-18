// ---------------------------------------------------------------------------------------
// Copyright by Jakub Suder (2009)
//
// xBlip is free software: you can redistribute it and/or modify it under the terms of the
// GNU General Public License as published by the Free Software Foundation, either version
// 2 of the License, or (at your option) any later version.
// ---------------------------------------------------------------------------------------

#import "XBlipAppDelegate.h"
#import "XBlipViewController.h"
#import "OBUtils.h"

@implementation XBlipAppDelegate

SynthesizeAndReleaseLater(window, viewController);

- (void) applicationDidFinishLaunching: (UIApplication *) application {
  // Override point for customization after app launch
  [window addSubview: viewController.view];
  [window makeKeyAndVisible];
}

@end

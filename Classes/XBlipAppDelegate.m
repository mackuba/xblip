// -------------------------------------------------------
// XBlipAppDelegate.m
//
// Copyright (c) 2009 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

#import "XBlipAppDelegate.h"
#import "XBlipViewController.h"
#import "OBUtils.h"

@implementation XBlipAppDelegate

@synthesize window, viewController;
OnDeallocRelease(window, viewController);

- (void) applicationDidFinishLaunching: (UIApplication *) application {
  // Override point for customization after app launch
  [window addSubview: viewController.view];
  [window makeKeyAndVisible];
}

@end

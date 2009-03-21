//
//  XBlipAppDelegate.m
//  XBlip
//
//  Created by Jakub Suder on 21-03-09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import "XBlipAppDelegate.h"
#import "XBlipViewController.h"

@implementation XBlipAppDelegate

@synthesize window;
@synthesize viewController;


- (void)applicationDidFinishLaunching:(UIApplication *)application {    
    
    // Override point for customization after app launch    
    [window addSubview:viewController.view];
    [window makeKeyAndVisible];
}


- (void)dealloc {
    [viewController release];
    [window release];
    [super dealloc];
}


@end

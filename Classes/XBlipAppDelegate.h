// ---------------------------------------------------------------------------------------
// Copyright by Jakub Suder (2009)
//
// xBlip is free software: you can redistribute it and/or modify it under the terms of the
// GNU General Public License as published by the Free Software Foundation, either version
// 2 of the License, or (at your option) any later version.
// ---------------------------------------------------------------------------------------

#import <UIKit/UIKit.h>

@class XBlipViewController;

@interface XBlipAppDelegate : NSObject <UIApplicationDelegate> {
  UIWindow *window;
  XBlipViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet XBlipViewController *viewController;

@end

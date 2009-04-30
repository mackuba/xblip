// -------------------------------------------------------
// XBlipAppDelegate.h
//
// Copyright (c) 2009 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

#import <UIKit/UIKit.h>

@class XBlipViewController;

@interface XBlipAppDelegate : NSObject <UIApplicationDelegate> {
  UIWindow *window;
  XBlipViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet XBlipViewController *viewController;

@end

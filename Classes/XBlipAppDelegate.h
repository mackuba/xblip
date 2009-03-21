//
//  XBlipAppDelegate.h
//  XBlip
//
//  Created by Jakub Suder on 21-03-09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import <UIKit/UIKit.h>

@class XBlipViewController;

@interface XBlipAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    XBlipViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet XBlipViewController *viewController;

@end


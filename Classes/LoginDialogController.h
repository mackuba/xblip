// ---------------------------------------------------------------------------------------
// Copyright by Jakub Suder (2009)
//
// xBlip is free software: you can redistribute it and/or modify it under the terms of the
// GNU General Public License as published by the Free Software Foundation, either version
// 2 of the License, or (at your option) any later version.
// ---------------------------------------------------------------------------------------

#import <UIKit/UIKit.h>

@class BlipConnection;
@class XBlipViewController;

@interface LoginDialogController : UIViewController <UITextFieldDelegate> {
  IBOutlet UITextField *usernameField;
  IBOutlet UITextField *passwordField;
  IBOutlet UILabel *connectingLabel;
  IBOutlet UILabel *incorrectLoginLabel;
  IBOutlet UIActivityIndicatorView *spinner;
  BlipConnection *blip;
  XBlipViewController *mainController;
}

- (id) initWithNibName: (NSString *) nibName
                bundle: (NSBundle *) bundle
                  blip: (BlipConnection *) blipInstance
        mainController: (XBlipViewController *) controller;

- (IBAction) newAccountPressed;
- (IBAction) loginPressed;

@end

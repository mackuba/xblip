// ---------------------------------------------------------------------------------------
// Copyright by Jakub Suder (2009)
//
// xBlip is free software: you can redistribute it and/or modify it under the terms of the
// GNU General Public License as published by the Free Software Foundation, either version
// 2 of the License, or (at your option) any later version.
// ---------------------------------------------------------------------------------------

#import <UIKit/UIKit.h>

@class OBConnector;
@class XBlipViewController;

@interface LoginDialogController : UIViewController <UITextFieldDelegate> {
  UITextField *usernameField;
  UITextField *passwordField;
  UILabel *connectingLabel;
  UILabel *incorrectLoginLabel;
  UIActivityIndicatorView *spinner;
  OBConnector *blip;
  XBlipViewController *mainController;
}

@property (nonatomic, retain) IBOutlet UITextField *usernameField;
@property (nonatomic, retain) IBOutlet UITextField *passwordField;
@property (nonatomic, retain) IBOutlet UILabel *connectingLabel;
@property (nonatomic, retain) IBOutlet UILabel *incorrectLoginLabel;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *spinner;

- (id) initWithNibName: (NSString *) nibName
                bundle: (NSBundle *) bundle
                  blip: (OBConnector *) blipInstance
        mainController: (XBlipViewController *) controller;

- (IBAction) newAccountPressed;
- (IBAction) loginPressed;

@end

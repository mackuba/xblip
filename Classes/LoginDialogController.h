// -------------------------------------------------------
// LoginDialogController.h
//
// Copyright (c) 2009 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

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
  __weak XBlipViewController *mainController;
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

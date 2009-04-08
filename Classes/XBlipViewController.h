// ---------------------------------------------------------------------------------------
// Copyright by Jakub Suder (2009)
//
// xBlip is free software: you can redistribute it and/or modify it under the terms of the
// GNU General Public License as published by the Free Software Foundation, either version
// 2 of the License, or (at your option) any later version.
// ---------------------------------------------------------------------------------------

#import <UIKit/UIKit.h>

@class BlipConnection;
@class LoginDialogController;

@interface XBlipViewController : UIViewController <UITextFieldDelegate> {
  UITextField *newMessageField;
  UITableView *tableView;
  BlipConnection *blip;
  LoginDialogController *loginController;
  NSMutableArray *messages;
}

@property (nonatomic, retain) IBOutlet UITextField *newMessageField;
@property (nonatomic, retain) IBOutlet UITableView *tableView;

- (IBAction) blipButtonClicked;
- (void) loginSuccessful;

@end

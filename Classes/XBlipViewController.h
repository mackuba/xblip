// -------------------------------------------------------
// XBlipViewController.h
//
// Copyright (c) 2009 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

#import <UIKit/UIKit.h>

@class OBConnector;
@class LoginDialogController;
@class MessageCell;

@interface XBlipViewController : UIViewController <UITextFieldDelegate> {
  UITextField *newMessageField;
  UITableView *tableView;
  OBConnector *blip;
  LoginDialogController *loginController;
  NSMutableArray *messages;
  BOOL firstConnection;
  MessageCell *currentCell;
}

@property (nonatomic, retain) IBOutlet UITextField *newMessageField;
@property (nonatomic, retain) IBOutlet UITableView *tableView;
@property (nonatomic, retain) IBOutlet MessageCell *currentCell;

- (IBAction) blipButtonClicked;
- (void) loginSuccessful;

@end

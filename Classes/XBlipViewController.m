// ---------------------------------------------------------------------------------------
// Copyright by Jakub Suder (2009)
//
// xBlip is free software: you can redistribute it and/or modify it under the terms of the
// GNU General Public License as published by the Free Software Foundation, either version
// 2 of the License, or (at your option) any later version.
// ---------------------------------------------------------------------------------------

#import "OBMessage.h"
#import "OBConnector.h"
#import "XBlipViewController.h"
#import "LoginDialogController.h"
#import "MessageCell.h"

#define USERNAME_KEY @"blipUsername"
#define PASSWORD_KEY @"blipPassword"
#define MESSAGE_CELL_TYPE @"messageCell"
#define USER_AGENT @"xBlip/0.1"
// TODO: get app version from configuration

@interface XBlipViewController ()
- (MessageCell *) createMessageCell;
- (void) prependMessageToLog: (OBMessage *) message;
- (void) saveLoginAndPassword;
- (void) scrollTextViewToTop;
- (void) sendMessage;
- (void) showLoginDialog;
@end

@implementation XBlipViewController

@synthesize newMessageField, tableView;

// -------------------------------------------------------------------------------------------
#pragma mark View initialization

- (void) awakeFromNib {
  messages = [[NSMutableArray alloc] init];
  NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
  NSString *username = [settings objectForKey: USERNAME_KEY];
  NSString *password = [settings objectForKey: PASSWORD_KEY]; // TODO: encode password?
  if (username && password) {
    blip = [[OBConnector alloc] initWithUsername: username password: password delegate: self];
    // check if the password is still OK
    firstConnection = YES;
    [blip authenticate];
  } else {
    blip = [[OBConnector alloc] init];
    firstConnection = NO;
  }
  blip.userAgent = USER_AGENT;
}

/*
// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}
*/

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/

- (void) viewDidAppear: (BOOL) animated {
  if (!blip.loggedIn && !firstConnection) {
    [self showLoginDialog];
  }
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

// -------------------------------------------------------------------------------------------
#pragma mark Authentication

- (void) showLoginDialog {
  loginController = [[LoginDialogController alloc] initWithNibName: @"LoginDialog"
                                                            bundle: [NSBundle mainBundle]
                                                              blip: blip
                                                    mainController: self];
  [self presentModalViewController: loginController animated: YES];
}

- (void) loginSuccessful {
  if (loginController) {
    [loginController dismissModalViewControllerAnimated: YES];
    [loginController release];
    loginController = nil;
    [self saveLoginAndPassword];
    blip.delegate = self;
  }
  // TODO: show "loading" while loading dashboard for the first time
  [blip getDashboard];
  [blip startMonitoringDashboard];
}

- (void) saveLoginAndPassword {
  NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
  [settings setObject: blip.username forKey: USERNAME_KEY];
  [settings setObject: blip.password forKey: PASSWORD_KEY];
  [settings synchronize];
}

// -------------------------------------------------------------------------------------------
#pragma mark Action handlers

- (IBAction) blipButtonClicked {
  [self sendMessage];
}

- (BOOL) textFieldShouldReturn: (UITextField *) textField {
  [self sendMessage];
  return YES;
}

- (void) sendMessage {
  [newMessageField resignFirstResponder];
  if (newMessageField.text.length > 0) {
    [blip sendMessage: newMessageField.text];
  }    
  newMessageField.text = @"";
}

- (void) prependMessageToLog: (OBMessage *) message {
  [tableView beginUpdates];
  [messages addObject: message];
  NSIndexPath *row = [NSIndexPath indexPathForRow: 0 inSection: 0];
  [tableView insertRowsAtIndexPaths: [NSArray arrayWithObject: row] withRowAnimation: UITableViewRowAnimationTop];
  [tableView endUpdates];
}

- (void) scrollTextViewToTop {
  [self.tableView setContentOffset: CGPointZero animated: YES];
}

// -------------------------------------------------------------------------------------------
#pragma mark Table view delegate / data source

- (NSInteger) tableView: (UITableView *) table numberOfRowsInSection: (NSInteger) section {
  return messages.count;
}

- (UITableViewCell *) tableView: (UITableView *) table cellForRowAtIndexPath: (NSIndexPath *) path {
  OBMessage *message = [messages objectAtIndex: path.row];
  MessageCell *cell = (MessageCell *) [table dequeueReusableCellWithIdentifier: MESSAGE_CELL_TYPE];
  if (!cell) {
    cell = [self createMessageCell];
  }
  [cell displayMessage: message];
  return cell;
}

- (CGFloat) tableView: (UITableView *) table heightForRowAtIndexPath: (NSIndexPath *) path {
  NSString *text = [[messages objectAtIndex: path.row] content];
  UIFont *font = [UIFont fontWithName: @"Helvetica" size: 13]; // TODO: read all attributes from NIB
  CGSize r = [text sizeWithFont: font
                   constrainedToSize: CGSizeMake(234, 10000)
                   lineBreakMode: UILineBreakModeTailTruncation];
  //NSLog(@"height/width of '%@' = %f/%f", text, r.height, r.width);
  return r.height + 20;
}

- (MessageCell *) createMessageCell {
  NSArray *nibContents = [[NSBundle mainBundle] loadNibNamed: @"MessageCell" owner: self options: nil];
  for (NSObject *nibItem in nibContents) {
    if ([nibItem isKindOfClass: [MessageCell class]]) {
      return (MessageCell *) nibItem;
    }
  }
  return nil;
}

// -------------------------------------------------------------------------------------------
#pragma mark OBConnector delegate callbacks

// TODO: display sent message after a response to send request, not when it comes back in messagesReceived
- (void) messagesReceived: (NSArray *) receivedMessages {
  NSLog(@"received %d messages", receivedMessages.count);
  if (receivedMessages.count > 0) {
    [self scrollTextViewToTop];
  }
  for (OBMessage *message in [receivedMessages reverseObjectEnumerator]) {
    NSLog(@"message %@ from %@", message.content, message.username);
    [self prependMessageToLog: message];
  }
}

- (void) authenticationFailed {
  [self showLoginDialog];
}

- (void) authenticationSuccessful {
  [self loginSuccessful];
}

- (void) requestFailedWithError: (NSError *) error {
  UIAlertView *alert = [[UIAlertView alloc] initWithTitle: [error localizedDescription]
                                                  message: [error localizedFailureReason]
                                                 delegate: nil
                                        cancelButtonTitle: @"OK"
                                        otherButtonTitles: nil];
  [alert show];
  [alert release];
}

// -------------------------------------------------------------------------------------------
#pragma mark Cleaning up

- (void) didReceiveMemoryWarning {
  [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
  // Release anything that's not essential, such as cached data
}

- (void) dealloc {
  [loginController release];
  [newMessageField release];
  [tableView release];
  [messages release];
  [blip release];
  [super dealloc];
}

@end

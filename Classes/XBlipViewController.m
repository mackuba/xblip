// -------------------------------------------------------
// XBlipViewController.m
//
// Copyright (c) 2009 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

#import "OBMessage.h"
#import "OBConnector.h"
#import "OBDashboardMonitor.h"
#import "OBRequest.h"
#import "OBUtils.h"
#import "Utils.h"
#import "XBlipViewController.h"
#import "LoginDialogController.h"
#import "MessageCell.h"

#define USERNAME_KEY @"blipUsername"
#define PASSWORD_KEY @"blipPassword"
#define MESSAGE_CELL_TYPE @"messageCell"
// TODO: get app version from configuration

@interface XBlipViewController ()
- (NSString *) errorResponseForNSError: (NSError *) nserror;
- (void) prependMessageToLog: (OBMessage *) message;
- (void) saveLoginAndPassword;
- (void) scrollTextViewToTop;
- (void) sendMessage;
- (void) showLoginDialog;
@end

@implementation XBlipViewController

@synthesize newMessageField, tableView, currentCell;

// -------------------------------------------------------------------------------------------
#pragma mark View initialization

- (void) awakeFromNib {
  messages = [[NSMutableArray alloc] init];
  NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
  NSString *username = [settings objectForKey: USERNAME_KEY];
  NSString *password = [settings objectForKey: PASSWORD_KEY]; // TODO: encode password?
  if (username && password) {
    blip = [[OBConnector alloc] initWithUsername: username password: password];
    // check if the password is still OK
    firstConnection = YES;
    [[blip authenticateRequest] sendFor: self];
  } else {
    blip = [[OBConnector alloc] init];
    firstConnection = NO;
  }
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
  }
  // TODO: show "loading" while loading dashboard for the first time
  Observe(blip.dashboardMonitor, OBDashboardUpdatedNotification, dashboardUpdatedWithMessages:);
  [blip.dashboardMonitor startMonitoring];
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
    [[blip sendMessageRequest: newMessageField.text] send];
  }    
  newMessageField.text = @"";
}

- (void) prependMessageToLog: (OBMessage *) message {
  [tableView beginUpdates];
  [messages insertObject: message atIndex: 0];
  NSIndexPath *row = [NSIndexPath indexPathForRow: 0 inSection: 0];
  [tableView insertRowsAtIndexPaths: OBArray(row) withRowAnimation: UITableViewRowAnimationTop];
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
    [[NSBundle mainBundle] loadNibNamed: @"MessageCell" owner: self options: nil];
    cell = currentCell;
  }
  [cell displayMessage: message];
  return cell;
}

- (CGFloat) tableView: (UITableView *) table heightForRowAtIndexPath: (NSIndexPath *) path {
  NSString *text = [[messages objectAtIndex: path.row] content];
  UIFont *font = [UIFont fontWithName: @"Helvetica" size: 13]; // TODO: read all attributes from NIB
  CGSize r = [text sizeWithFont: font
                   constrainedToSize: CGSizeMake(227, 10000)
                   lineBreakMode: UILineBreakModeWordWrap];
  return r.height + 20;
}

// -------------------------------------------------------------------------------------------
#pragma mark OBConnector delegate callbacks

// TODO: display sent message after a response to send request, not when it comes back in messagesReceived
- (void) dashboardUpdatedWithMessages: (NSNotification *) notification {
  NSArray *receivedMessages = [notification.userInfo objectForKey: @"messages"];
  NSLog(@"received %d messages", receivedMessages.count);
  if (receivedMessages.count > 0) {
    [self scrollTextViewToTop];
  }
  // first message in the array is the latest one, so we want it to be added as the last one
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

- (NSString *) errorResponseForNSError: (NSError *) nserror {
  if (nserror.domain == NSURLErrorDomain) {
    switch (nserror.code) {
      case NSURLErrorTimedOut: return @"Can't connect to Blip server.";
    }
  }
  return [nserror localizedDescription];
}

- (void) requestFailedWithError: (NSError *) error {
  [Utils showAlertWithTitle: @"Error" content: [self errorResponseForNSError: error]];
}

// -------------------------------------------------------------------------------------------
#pragma mark Cleaning up

- (void) didReceiveMemoryWarning {
  [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
  // Release anything that's not essential, such as cached data
}

- (void) dealloc {
  ReleaseAll(newMessageField, tableView, currentCell, loginController, messages, blip);
  [super dealloc];
}

@end

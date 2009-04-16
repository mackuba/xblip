// ---------------------------------------------------------------------------------------
// Copyright by Jakub Suder (2009)
//
// xBlip is free software: you can redistribute it and/or modify it under the terms of the
// GNU General Public License as published by the Free Software Foundation, either version
// 2 of the License, or (at your option) any later version.
// ---------------------------------------------------------------------------------------

#import "OBUtils.h"
#import "OBMessage.h"
#import "OBConnector.h"
#import "NSArray+BSJSONAdditions.h"

#import "XBlipViewController.h"
#import "LoginDialogController.h"
#import "HTTPStatusCodes.h"
#import "MessageCell.h"

#define USERNAME_KEY @"blipUsername"
#define PASSWORD_KEY @"blipPassword"
#define MESSAGE_CELL_TYPE @"messageCell"

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

- (void) awakeFromNib {
  messages = [[NSMutableArray alloc] init];
  NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
  NSString *username = [settings objectForKey: USERNAME_KEY];
  NSString *password = [settings objectForKey: PASSWORD_KEY]; // TODO: encode password?
  if (username && password) {
    blip = [[OBConnector alloc] initWithUsername: username password: password delegate: self];
    // check if the password is still OK
    // TODO: [blip authenticate];
    blip.loggedIn = true;
  } else {
    blip = [[OBConnector alloc] init];
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
  if (!blip.loggedIn) {
    [self showLoginDialog];
  } else {
    // TODO: we should start monitoring after we check the password...
    [blip getDashboard];
    [blip startMonitoringDashboard];
  }
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void) showLoginDialog {
  loginController = [[LoginDialogController alloc] initWithNibName: @"LoginDialog"
                                                            bundle: [NSBundle mainBundle]
                                                              blip: blip
                                                    mainController: self];
  [self presentModalViewController: loginController animated: YES];
}

- (void) loginSuccessful {
  [loginController dismissModalViewControllerAnimated: YES];
  [loginController release];
  loginController = nil;
  blip.delegate = self;
  blip.loggedIn = true;
  [self saveLoginAndPassword];
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
  NSLog(@"added message: %@", [message content]);
  NSIndexPath *row = [NSIndexPath indexPathForRow: 0 inSection: 0];
  [tableView insertRowsAtIndexPaths: [NSArray arrayWithObject: row] withRowAnimation: UITableViewRowAnimationTop];
  [tableView endUpdates];
}

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
  NSLog(@"height/width of '%@' = %f/%f", text, r.height, r.width);
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

- (void) scrollTextViewToTop {
  [self.tableView setContentOffset: CGPointZero animated: YES];
}

- (void) didReceiveMemoryWarning {
  [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
  // Release anything that's not essential, such as cached data
}

- (void) requestFinishedWithResponse: (NSURLResponse *) response text: (NSString *) text {
  NSString *trimmed = [OBUtils trimmedString: text];
  if ([OBUtils string: trimmed startsWithCharacter: '[']) {
    NSArray *receivedMessages = [NSArray arrayWithJSONString: trimmed];
    NSLog(@"received %d messages", receivedMessages.count);
    if (receivedMessages.count > 0) {
      [self scrollTextViewToTop];
    }
    for (NSDictionary *object in [receivedMessages reverseObjectEnumerator]) {
      NSString *userPath = [object objectForKey: @"user_path"];
      NSString *userName = [[userPath componentsSeparatedByString: @"/"] objectAtIndex: 2];
      NSString *body = [object objectForKey: @"body"];
      NSLog(@"message %@ from %@", body, userName);
      OBMessage *message = [[OBMessage alloc] initWithContent: body fromUser: userName];
      [self prependMessageToLog: message];
      [message release];
    }
  }
}

- (void) authenticationRequired: (NSURLAuthenticationChallenge *) challenge {
  UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Login error"
                                                  message: @"Invalid username or password."
                                                 delegate: nil
                                        cancelButtonTitle: @"OK"
                                        otherButtonTitles: nil];
  [alert show];
  [alert release];
  [[challenge sender] cancelAuthenticationChallenge: challenge];
  // TODO: show login dialog again?
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

- (void) dealloc {
  [loginController release];
  [newMessageField release];
  [blip release];
  [super dealloc];
}

@end

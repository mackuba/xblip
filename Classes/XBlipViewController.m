// ---------------------------------------------------------------------------------------
// Copyright by Jakub Suder (2009)
//
// xBlip is free software: you can redistribute it and/or modify it under the terms of the
// GNU General Public License as published by the Free Software Foundation, either version
// 2 of the License, or (at your option) any later version.
// ---------------------------------------------------------------------------------------

#import "XBlipViewController.h"
#import "LoginDialogController.h"
#import "BlipConnection.h"
#import "HTTPStatusCodes.h"
#import "NSArray+BSJSONAdditions.h"
#import "OBUtils.h"

@interface XBlipViewController ()
- (void) prependMessageToLog: (NSString *) message;
- (void) sendMessage;
- (void) showLoginDialog;
- (void) scrollTextViewToTop;
@end

@implementation XBlipViewController

- (void) awakeFromNib {
  NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
  NSString *username = [settings objectForKey: @"blipUsername"];
  NSString *password = [settings objectForKey: @"blipPassword"]; // TODO: encode password?
  if (username && password) {
    blip = [[BlipConnection alloc] initWithUsername: username password: password delegate: self];
    // check if the password is still OK
    // TODO: [blip authenticate];
    blip.loggedIn = true;
  } else {
    blip = [[BlipConnection alloc] init];
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
  NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
  [settings setObject: blip.username forKey: @"blipUsername"];
  [settings setObject: blip.password forKey: @"blipPassword"];
  [settings synchronize];
  [blip getDashboard];
  [blip startMonitoringDashboard];
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

- (void) prependMessageToLog: (NSString *) message {
  // TODO: is there a way to append a line without copying the whole contents of the view?
  messageLog.text = [NSString stringWithFormat: @"%@\n%@", message, messageLog.text];
}

- (void) scrollTextViewToTop {
  [messageLog scrollRangeToVisible: NSMakeRange(0, 0)];
}

- (void) didReceiveMemoryWarning {
  [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
  // Release anything that's not essential, such as cached data
}

- (void) requestFinishedWithResponse: (NSURLResponse *) response text: (NSString *) text {
  NSString *trimmed = [OBUtils trimmedString: text];
  if ([OBUtils string: trimmed startsWithCharacter: '[']) {
    NSArray *messages = [NSArray arrayWithJSONString: trimmed];
    for (NSDictionary *object in [messages reverseObjectEnumerator]) {
      NSString *userPath = [object objectForKey: @"user_path"];
      NSString *userName = [[userPath componentsSeparatedByString: @"/"] objectAtIndex: 2];
      NSString *body = [object objectForKey: @"body"];
      NSString *message = [[NSString alloc] initWithFormat: @"%@: %@", userName, body];
      [self prependMessageToLog: message];
      [message release];
    }
    [self scrollTextViewToTop];
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
  [messageLog release];
  [blip release];
  [super dealloc];
}

@end

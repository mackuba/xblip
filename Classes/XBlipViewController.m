// ---------------------------------------------------------------------------------------
// Copyright by Jakub Suder (2009)
//
// xBlip is free software: you can redistribute it and/or modify it under the terms of the
// GNU General Public License as published by the Free Software Foundation, either version
// 2 of the License, or (at your option) any later version.
// ---------------------------------------------------------------------------------------

#import "XBlipViewController.h"
#import "BlipConnection.h"
#import "HTTPStatusCodes.h"
#import "NSArray+BSJSONAdditions.h"

@interface XBlipViewController ()
- (void) appendMessageToLog: (NSString *) message;
- (void) prependMessageToLog: (NSString *) message;
- (void) sendMessage;
- (void) scrollTextViewToTop;
@end

@implementation XBlipViewController

- (void) awakeFromNib {
  // TODO: take password from a dialog
  blip = [[BlipConnection alloc] initWithUsername: @"xblip" password: @"....." delegate: self];
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

- (void) viewDidLoad {
  [super viewDidLoad];
  [blip getDashboard];
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

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
}

- (void) prependMessageToLog: (NSString *) message {
  // TODO: is there a way to append a line without copying the whole contents of the view?
  messageLog.text = [NSString stringWithFormat: @"%@\n%@", message, messageLog.text];
}

- (void) appendMessageToLog: (NSString *) message {
  messageLog.text = [messageLog.text stringByAppendingFormat: @"%@\n", message];
}

- (void) scrollTextViewToTop {
  [messageLog scrollRangeToVisible: NSMakeRange(0, 0)];
}

- (void) didReceiveMemoryWarning {
  [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
  // Release anything that's not essential, such as cached data
}

- (void) requestFinishedWithResponse: (NSURLResponse *) response text: (NSString *) text {
  NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
  // TODO: refactor BlipConnection so that it knows which response matches which request
  if ([httpResponse statusCode] == HTTP_STATUS_CREATED) { // Created
    [self prependMessageToLog: [NSString stringWithFormat: @"%@: %@", blip.username, newMessageField.text]];
    newMessageField.text = @"";
    [self scrollTextViewToTop];
  } else {
    NSArray *messages = [NSArray arrayWithJSONString: text];
    for (NSDictionary *object in messages) {
      NSString *userPath = [object objectForKey: @"user_path"];
      NSString *userName = [[userPath componentsSeparatedByString: @"/"] objectAtIndex: 2];
      NSString *body = [object objectForKey: @"body"];
      NSString *message = [[NSString alloc] initWithFormat: @"%@: %@", userName, body];
      [self appendMessageToLog: message];
      [message release];
    }
    [self scrollTextViewToTop];
  }
}

- (void) authenticationRequired {
  UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Login error"
                                                  message: @"Invalid username or password."
                                                 delegate: nil
                                        cancelButtonTitle: @"OK"
                                        otherButtonTitles: nil];
  [alert show];
  [alert release];
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
  [newMessageField dealloc];
  [messageLog dealloc];
  [blip dealloc];
  [super dealloc];
}

@end

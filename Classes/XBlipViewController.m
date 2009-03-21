//
//  XBlipViewController.m
//  XBlip
//
//  Created by Jakub Suder on 21-03-09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import "XBlipViewController.h"
#import "BlipConnection.h"

@interface XBlipViewController ()
- (void) sendMessage;
- (void) scrollTextViewToBottom;
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
  // TODO: send message
  [newMessageField resignFirstResponder];
  NSString *message = newMessageField.text;
  messageLog.text = [messageLog.text stringByAppendingFormat: @"%@\n", message];
  newMessageField.text = @"";
  [self scrollTextViewToBottom];
}

- (void) scrollTextViewToBottom {
  [messageLog scrollRangeToVisible: NSMakeRange(messageLog.text.length, 0)];
}

- (void) didReceiveMemoryWarning {
  [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
  // Release anything that's not essential, such as cached data
}

- (void) requestFinishedWithResponse: (NSURLResponse *) response text: (NSString *) text {
  messageLog.text = [messageLog.text stringByAppendingString: text];
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

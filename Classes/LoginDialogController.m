// ---------------------------------------------------------------------------------------
// Copyright by Jakub Suder (2009)
//
// xBlip is free software: you can redistribute it and/or modify it under the terms of the
// GNU General Public License as published by the Free Software Foundation, either version
// 2 of the License, or (at your option) any later version.
// ---------------------------------------------------------------------------------------

#import "LoginDialogController.h"
#import "XBlipViewController.h"
#import "BlipConnection.h"

@implementation LoginDialogController

@synthesize usernameField, passwordField, connectingLabel, incorrectLoginLabel, spinner;

- (id) initWithNibName: (NSString *) nibName
                bundle: (NSBundle *) bundle
                  blip: (BlipConnection *) blipInstance
        mainController: (XBlipViewController *) controller {
  if (self = [super initWithNibName: nibName bundle: bundle]) {
    blip = [blipInstance retain];
    blip.delegate = self;
    mainController = controller;
  }
  return self;
}

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/

- (void) viewDidAppear: (BOOL) animated {
  [usernameField becomeFirstResponder];
}

- (IBAction) newAccountPressed {
  // TODO: implement redirecting to Safari to http://blip.pl/users/new
}

- (IBAction) loginPressed {
  if (usernameField.text.length > 0 && passwordField.text.length > 0) {
    [usernameField resignFirstResponder];
    [passwordField resignFirstResponder];
    [blip setUsername: usernameField.text password: passwordField.text];
    [blip authenticate];
    [spinner startAnimating];
    incorrectLoginLabel.hidden = YES;
    connectingLabel.hidden = NO;
  }
}

- (BOOL) textFieldShouldReturn: (UITextField *) textField {
  if (textField.text.length == 0) {
    return NO;
  } else {
    if (textField == usernameField) {
      [passwordField becomeFirstResponder];
    } else if (textField == passwordField) {
      [textField resignFirstResponder];
      [self loginPressed];
    }
    return YES;
  }
}

- (void) requestFinishedWithResponse: (NSURLResponse *) response text: (NSString *) text {
  // authentication successful
  [mainController loginSuccessful];
}

- (void) requestRedirected {
  // authentication successful
  [mainController loginSuccessful];
}

- (void) authenticationRequired: (NSURLAuthenticationChallenge *) challenge {
  // authentication failed
  [spinner stopAnimating];
  connectingLabel.hidden = YES;
  incorrectLoginLabel.hidden = NO;
  [[challenge sender] cancelAuthenticationChallenge: challenge];
  // TODO: reuse connection instead of cancelling it?
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void) didReceiveMemoryWarning {
  [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
  // Release anything that's not essential, such as cached data
}

- (void) dealloc {
  [usernameField release];
  [passwordField release];
  [blip release];
  [connectingLabel release];
  [spinner release];
  [super dealloc];
}

@end

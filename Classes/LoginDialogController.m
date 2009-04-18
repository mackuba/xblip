// ---------------------------------------------------------------------------------------
// Copyright by Jakub Suder (2009)
//
// xBlip is free software: you can redistribute it and/or modify it under the terms of the
// GNU General Public License as published by the Free Software Foundation, either version
// 2 of the License, or (at your option) any later version.
// ---------------------------------------------------------------------------------------

#import "LoginDialogController.h"
#import "XBlipViewController.h"
#import "OBConnector.h"
#import "OBUtils.h"

@implementation LoginDialogController

@synthesize usernameField, passwordField, connectingLabel, incorrectLoginLabel, spinner;
OnDeallocRelease(usernameField, passwordField, connectingLabel, incorrectLoginLabel, spinner, blip);

// -------------------------------------------------------------------------------------------
#pragma mark Initializers

- (id) initWithNibName: (NSString *) nibName
                bundle: (NSBundle *) bundle
                  blip: (OBConnector *) blipInstance
        mainController: (XBlipViewController *) controller {
  if (self = [super initWithNibName: nibName bundle: bundle]) {
    blip = [blipInstance retain];
    blip.delegate = self;
    mainController = controller;
  }
  return self;
}

// -------------------------------------------------------------------------------------------
#pragma mark View initialization

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/

- (void) viewDidAppear: (BOOL) animated {
  [usernameField becomeFirstResponder];
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

// -------------------------------------------------------------------------------------------
#pragma mark Action handlers

- (IBAction) newAccountPressed {
  NSURL *registerURL = [NSURL URLWithString: @"http://blip.pl/users/new"];
  [[UIApplication sharedApplication] openURL: registerURL];
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

// -------------------------------------------------------------------------------------------
#pragma mark OBConnector delegate callbacks

- (void) authenticationSuccessful {
  [mainController loginSuccessful];
}

- (void) authenticationFailed {
  [spinner stopAnimating];
  connectingLabel.hidden = YES;
  incorrectLoginLabel.hidden = NO;
}

// -------------------------------------------------------------------------------------------
#pragma mark Cleaning up

- (void) didReceiveMemoryWarning {
  [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
  // Release anything that's not essential, such as cached data
}

@end

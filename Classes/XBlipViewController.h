//
//  XBlipViewController.h
//  XBlip
//
//  Created by Jakub Suder on 21-03-09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BlipConnection;

@interface XBlipViewController : UIViewController <UITextFieldDelegate> {
  IBOutlet UITextField *newMessageField;
  IBOutlet UITextView *messageLog;
  BlipConnection *blip;
}

- (IBAction) blipButtonClicked;

@end

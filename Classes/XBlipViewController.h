//
//  XBlipViewController.h
//  XBlip
//
//  Created by Jakub Suder on 21-03-09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface XBlipViewController : UIViewController <UITextFieldDelegate> {
  IBOutlet UITextField *newMessageField;
  IBOutlet UITextView *messageLog;
}

- (IBAction) blipButtonClicked;

@end


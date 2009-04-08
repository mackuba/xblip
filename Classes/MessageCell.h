// ---------------------------------------------------------------------------------------
// Copyright by Jakub Suder (2009)
//
// xBlip is free software: you can redistribute it and/or modify it under the terms of the
// GNU General Public License as published by the Free Software Foundation, either version
// 2 of the License, or (at your option) any later version.
// ---------------------------------------------------------------------------------------

#import <UIKit/UIKit.h>

@class Message;

@interface MessageCell : UITableViewCell {
  UILabel *usernameLabel;
  UITextView *content;
}

@property (nonatomic, retain) IBOutlet UILabel *usernameLabel;
@property (nonatomic, retain) IBOutlet UITextView *content;

- (void) displayMessage: (Message *) message;

@end

// -------------------------------------------------------
// MessageCell.h
//
// Copyright (c) 2009 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

#import <UIKit/UIKit.h>

@class OBMessage;

@interface MessageCell : UITableViewCell {
  UILabel *usernameLabel;
  UILabel *contentLabel;
}

@property (nonatomic, retain) IBOutlet UILabel *usernameLabel;
@property (nonatomic, retain) IBOutlet UILabel *contentLabel;

- (void) displayMessage: (OBMessage *) message;

@end

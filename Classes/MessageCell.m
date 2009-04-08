// ---------------------------------------------------------------------------------------
// Copyright by Jakub Suder (2009)
//
// xBlip is free software: you can redistribute it and/or modify it under the terms of the
// GNU General Public License as published by the Free Software Foundation, either version
// 2 of the License, or (at your option) any later version.
// ---------------------------------------------------------------------------------------

#import "MessageCell.h"
#import "Message.h"

@implementation MessageCell

@synthesize content, usernameLabel;

- (id) initWithFrame: (CGRect) frame reuseIdentifier: (NSString *) reuseIdentifier {
  if (self = [super initWithFrame: frame reuseIdentifier: reuseIdentifier]) {
    // Initialization code
  }
  return self;
}

- (void) displayMessage: (Message *) message {
  content.text = message.content;
  usernameLabel.text = message.username;
}

- (void) setSelected: (BOOL) selected animated: (BOOL) animated {
  [super setSelected: selected animated: animated];
  // Configure the view for the selected state
}

- (void) dealloc {
  [super dealloc];
}

@end

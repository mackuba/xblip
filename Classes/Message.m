// ---------------------------------------------------------------------------------------
// Copyright by Jakub Suder (2009)
//
// xBlip is free software: you can redistribute it and/or modify it under the terms of the
// GNU General Public License as published by the Free Software Foundation, either version
// 2 of the License, or (at your option) any later version.
// ---------------------------------------------------------------------------------------

#import "Message.h"

@implementation Message

@synthesize username, content;

- (id) initWithContent: (NSString *) messageContent fromUser: (NSString *) senderUsername {
  if (self = [super init]) {
    self.content = messageContent;
    self.username = senderUsername;
  }
  return self;
}

@end

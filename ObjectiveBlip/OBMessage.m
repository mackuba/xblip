// -------------------------------------------------------------------------------------------
// "THE BEER-WARE LICENSE" (Revision 42):
// Jakub Suder <jakub.suder@gmail.com> wrote this file. As long as you retain this notice
// you can do whatever you want with this stuff. If we meet some day, and you think this
// stuff is worth it, you can buy me a beer in return.
// (License text originally created by Poul-Henning Kamp, http://people.freebsd.org/~phk/)
// -------------------------------------------------------------------------------------------

#import "OBMessage.h"

@implementation OBMessage

@synthesize username, content;

- (id) initWithContent: (NSString *) messageContent fromUser: (NSString *) senderUsername {
  if (self = [super init]) {
    self.content = messageContent;
    self.username = senderUsername;
  }
  return self;
}

@end

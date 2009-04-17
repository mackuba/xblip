// -------------------------------------------------------------------------------------------
// "THE BEER-WARE LICENSE" (Revision 42):
// Jakub Suder <jakub.suder@gmail.com> wrote this file. As long as you retain this notice
// you can do whatever you want with this stuff. If we meet some day, and you think this
// stuff is worth it, you can buy me a beer in return.
// (License text originally created by Poul-Henning Kamp, http://people.freebsd.org/~phk/)
// -------------------------------------------------------------------------------------------

#import "OBMessage.h"
#import "NSArray+BSJSONAdditions.h"

@implementation OBMessage

@synthesize messageId, username, content;

- (id) initWithId: (NSInteger) _messageId
          content: (NSString *) _content
         fromUser: (NSString *) _username {
  if (self = [super init]) {
    self.messageId = _messageId;
    self.content = _content;
    self.username = _username;
  }
  return self;
}

+ (NSArray *) messagesFromJSON: (NSString *) json {
  NSArray *records = [NSArray arrayWithJSONString: json];
  NSMutableArray *messages = [NSMutableArray arrayWithCapacity: records.count];
  for (NSDictionary *record in records) {
    NSString *userPath = [record objectForKey: @"user_path"];
    NSInteger messageId = [[record objectForKey: @"id"] intValue];
    NSString *userName = [[userPath componentsSeparatedByString: @"/"] objectAtIndex: 2];
    NSString *body = [record objectForKey: @"body"];
    OBMessage *message = [[OBMessage alloc] initWithId: messageId content: body fromUser: userName];
    [messages addObject: message];
    [message release];
  }
  return messages;
}

@end

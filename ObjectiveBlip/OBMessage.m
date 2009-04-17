// -------------------------------------------------------------------------------------------
// "THE BEER-WARE LICENSE" (Revision 42):
// Jakub Suder <jakub.suder@gmail.com> wrote this file. As long as you retain this notice
// you can do whatever you want with this stuff. If we meet some day, and you think this
// stuff is worth it, you can buy me a beer in return.
// (License text originally created by Poul-Henning Kamp, http://people.freebsd.org/~phk/)
// -------------------------------------------------------------------------------------------

#import "NSArray+BSJSONAdditions.h"
#import "OBMessage.h"

@implementation OBMessage

@synthesize messageId, username, content;

+ (NSArray *) messagesFromJSONString: (NSString *) json {
  NSArray *records = [NSArray arrayWithJSONString: json];
  NSMutableArray *messages = [NSMutableArray arrayWithCapacity: records.count];
  for (NSDictionary *record in records) {
    OBMessage *message = [[OBMessage alloc] initWithJSON: record];
    [messages addObject: message];
    [message release];
  }
  return messages;
}

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

- (id) initWithJSON: (NSDictionary *) json {
  NSString *userPath = [json objectForKey: @"user_path"];
  NSInteger msgId = [[json objectForKey: @"id"] intValue];
  NSString *userName = [[userPath componentsSeparatedByString: @"/"] objectAtIndex: 2];
  NSString *body = [json objectForKey: @"body"];
  return [self initWithId: msgId content: body fromUser: userName];
}

- (void) dealloc {
  [username release];
  [content release];
  [super dealloc];
}

@end

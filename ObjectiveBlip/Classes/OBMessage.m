// -------------------------------------------------------
// OBMessage.m
//
// Copyright (c) 2009 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

#import "NSArray+BSJSONAdditions.h"
#import "OBMessage.h"
#import "OBUtils.h"

@implementation OBMessage

@synthesize messageId, username, content;
OnDeallocRelease(username, content);

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

@end

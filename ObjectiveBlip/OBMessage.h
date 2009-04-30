// -------------------------------------------------------
// OBMessage.h
//
// Copyright (c) 2009 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

#import <Foundation/Foundation.h>

@interface OBMessage : NSObject {
  NSInteger messageId;
  NSString *content;
  NSString *username;
}

@property (nonatomic) NSInteger messageId;
@property (nonatomic, copy) NSString *content;
@property (nonatomic, copy) NSString *username;

+ (NSArray *) messagesFromJSONString: (NSString *) json;

- (id) initWithId: (NSInteger) messageId
          content: (NSString *) content
         fromUser: (NSString *) username;

- (id) initWithJSON: (NSDictionary *) json;

@end

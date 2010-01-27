// -------------------------------------------------------
// OBRequest.h
//
// Copyright (c) 2009 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

#import <Foundation/Foundation.h>
#import "ASIHTTPRequest.h"

typedef enum {
  OBDashboardRequest = 1,
  OBSendMessageRequest,
  OBAuthenticationRequest
} OBRequestType;

@interface OBRequest : ASIHTTPRequest {
  OBRequestType type;
}

@property (nonatomic) OBRequestType type;

+ (OBRequest *) requestSendingMessage: (NSString *) message;
+ (OBRequest *) requestForDashboard;
+ (OBRequest *) requestForDashboardSince: (NSInteger) lastMessageId;
+ (OBRequest *) requestForAuthentication;

- (id) initWithPath: (NSString *) path
             method: (NSString *) method
               text: (NSString *) text
               type: (OBRequestType) type;

- (id) initWithPath: (NSString *) path
             method: (NSString *) method
               type: (OBRequestType) type;

- (id) initWithPath: (NSString *) path
               type: (OBRequestType) type;

@end

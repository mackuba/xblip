// -------------------------------------------------------
// OBRequest.h
//
// Copyright (c) 2009 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

#import <Foundation/Foundation.h>

typedef enum {
  OBDashboardRequest = 1,
  OBSendMessageRequest,
  OBAuthenticationRequest
} OBRequestType;

@interface OBRequest : NSMutableURLRequest {
  OBRequestType type;
  NSURLResponse *response;
  NSString *sentText;
  NSMutableString *receivedText;
}

@property (nonatomic) OBRequestType type;
@property (nonatomic, retain) NSURLResponse *response;
@property (nonatomic, readonly) NSString *sentText;
@property (nonatomic, readonly) NSMutableString *receivedText;

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

- (void) appendReceivedText: (NSString *) text;
- (void) setValueIfNotEmpty: (NSString *) value forHTTPHeaderField: (NSString *) field;

@end

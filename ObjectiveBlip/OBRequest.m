// -------------------------------------------------------
// OBRequest.m
//
// Copyright (c) 2009 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

#import "NSString+BSJSONAdditions.h"
#import "Constants.h"
#import "OBRequest.h"
#import "OBUtils.h"

#define SetHeader(key, value) [self setValue: value forHTTPHeaderField: key]

@implementation OBRequest

@synthesize type;
SynthesizeAndReleaseLater(response, receivedText, sentText);

// -------------------------------------------------------------------------------------------
#pragma mark Initializers

- (id) initWithPath: (NSString *) path
             method: (NSString *) method
               text: (NSString *) text
               type: (OBRequestType) requestType {
  self = [super initWithURL: [NSURL URLWithString: [BLIP_API_HOST stringByAppendingString: path]]
                cachePolicy: NSURLRequestReloadIgnoringLocalCacheData
            timeoutInterval: 15];
  if (self) {
    self.type = requestType;
    self.HTTPMethod = method;
    receivedText = [[NSMutableString alloc] init];
    sentText = [text copy];
    SetHeader(@"X-Blip-API", BLIP_API_VERSION);
    SetHeader(@"Accept", @"application/json");
    if (sentText) {
      SetHeader(@"Content-Type", @"application/json");
      self.HTTPBody = [sentText dataUsingEncoding: NSUTF8StringEncoding];
    }
  }
  return self;
}

- (id) initWithPath: (NSString *) path
             method: (NSString *) method
               type: (OBRequestType) requestType {
  return [self initWithPath: path method: method text: @"" type: requestType];
}

- (id) initWithPath: (NSString *) path
               type: (OBRequestType) requestType {
  return [self initWithPath: path method: @"GET" text: @"" type: requestType];
}

// -------------------------------------------------------------------------------------------
#pragma mark Request generators

+ (OBRequest *) requestSendingMessage: (NSString *) message {
  NSString *content = OBFormat(@"{\"update\": {\"body\": %@}}", [message jsonStringValue]);
  OBRequest *request = [[OBRequest alloc] initWithPath: @"/updates"
                                                method: @"POST"
                                                  text: content
                                                  type: OBSendMessageRequest];
  return [request autorelease];
}

+ (OBRequest *) requestForDashboard {
  return [[[OBRequest alloc] initWithPath: @"/dashboard" type: OBDashboardRequest] autorelease];
}

+ (OBRequest *) requestForDashboardSince: (NSInteger) lastMessageId {
  NSString *path = OBFormat(@"/dashboard/since/%d", lastMessageId);
  return [[[OBRequest alloc] initWithPath: path type: OBDashboardRequest] autorelease];
}

+ (OBRequest *) requestForAuthentication {
  return [[[OBRequest alloc] initWithPath: @"/login" type: OBAuthenticationRequest] autorelease];
}

// -------------------------------------------------------------------------------------------
#pragma mark Instance methods

- (void) appendReceivedText: (NSString *) text {
  [receivedText appendString: text];
}

- (void) setValueIfNotEmpty: (NSString *) value forHTTPHeaderField: (NSString *) field {
  if (value) SetHeader(field, value);
}

@end

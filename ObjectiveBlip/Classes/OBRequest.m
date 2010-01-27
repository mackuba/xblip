// -------------------------------------------------------
// OBRequest.m
//
// Copyright (c) 2009 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

#import "Constants.h"
#import "OBRequest.h"
#import "OBUtils.h"
#import "NSString+BSJSONAdditions.h"

@implementation OBRequest

@synthesize type;

// -------------------------------------------------------------------------------------------
#pragma mark Initializers

- (id) initWithPath: (NSString *) path
             method: (NSString *) method
               text: (NSString *) text
               type: (OBRequestType) requestType {
  NSURL *wrappedUrl = [NSURL URLWithString: [BLIP_API_HOST stringByAppendingString: path]];
  self = [super initWithURL: wrappedUrl];
  if (self) {
    self.timeOutSeconds = 15;
    self.type = requestType;
    self.requestMethod = method;
    [self addRequestHeader: @"X-Blip-API" value: BLIP_API_VERSION];
    [self addRequestHeader: @"User-Agent" value: BLIP_USER_AGENT];
    [self addRequestHeader: @"Accept" value: @"application/json"];
    [self addRequestHeader: @"Content-Type" value: @"application/json"];
    if (text) {
      [self appendPostData: [text dataUsingEncoding: NSUTF8StringEncoding]];
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

@end

// -------------------------------------------------------
// OBConnector.m
//
// Copyright (c) 2009 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

#import "Constants.h"
#import "OBConnector.h"
#import "OBRequest.h"
#import "OBMessage.h"
#import "OBUtils.h"
#import "NSString+BSJSONAdditions.h"

#define SafeDelegateCall(method, ...) \
  if ([delegate respondsToSelector: @selector(method)]) [delegate method __VA_ARGS__]

@interface NSObject (OBConnectorDelegate)
- messageSent;
- messagesReceived: (NSArray *) messages;
- authenticationSuccessful;
- authenticationFailed;
- requestFailedWithError: (NSError *) error;
@end

@interface OBConnector ()
- (void) sendRequest: (OBRequest *) request handler: (SEL) handler;
@end


@implementation OBConnector

@synthesize username, delegate, loggedIn, password;

// -------------------------------------------------------------------------------------------
#pragma mark Initializers

- (id) initWithUsername: (NSString *) aUsername
               password: (NSString *) aPassword
               delegate: (id) aDelegate {
  if (self = [super init]) {
    [self setUsername: aUsername password: aPassword];
    delegate = aDelegate;
    lastMessageId = -1;
    loggedIn = NO;
    isSendingDashboardRequest = NO;
    currentRequests = [[NSMutableArray alloc] initWithCapacity: 5];
  }
  return self;
}

- (id) init {
  return [self initWithUsername: nil password: nil delegate: nil];
}

// -------------------------------------------------------------------------------------------
#pragma mark Instance methods

- (void) setUsername: (NSString *) aUsername password: (NSString *) aPassword {
  [username autorelease];
  [password autorelease];
  username = [aUsername copy];
  password = [aPassword copy];
}

- (void) startMonitoringDashboard {
  [self stopMonitoringDashboard];
  monitorTimer = [NSTimer scheduledTimerWithTimeInterval: 10
                                                  target: self
                                                selector: @selector(dashboardTimerFired:)
                                                userInfo: nil
                                                 repeats: YES];
  [monitorTimer retain];
}

- (void) stopMonitoringDashboard {
  [monitorTimer invalidate];
  monitorTimer = nil;
}

- (void) dashboardTimerFired: (NSTimer *) timer {
  if (!isSendingDashboardRequest) {
    isSendingDashboardRequest = YES;
    [self getDashboard];
  }
}

// -------------------------------------------------------------------------------------------
#pragma mark Request sending

- (void) authenticate {
  OBRequest *request = [OBRequest requestWithPath: @"/login" method: @"GET" text: nil];
  [self sendRequest: request handler: @selector(authenticationSuccessful:)];
}

- (void) getDashboard {
  NSString *path = (lastMessageId > 0) ? OBFormat(@"/dashboard/since/%d", lastMessageId) : @"/dashboard";
  OBRequest *request = [OBRequest requestWithPath: path method: @"GET" text: nil];
  [self sendRequest: request handler: @selector(dashboardUpdated:)];
}

- (void) sendMessage: (NSString *) message {
  NSString *content = OBFormat(@"{\"update\": {\"body\": %@}}", [message jsonStringValue]);
  OBRequest *request = [OBRequest requestWithPath: @"/updates" method: @"POST" text: content];
  [self sendRequest: request handler: @selector(messageSent:)];
}

- (void) sendRequest: (OBRequest *) request handler: (SEL) handler {
  [request addBasicAuthenticationHeaderWithUsername: username andPassword: password];
  [request setDelegate: self];
  [request setDidFinishSelector: handler];
  [request setDidFailSelector: @selector(requestFailed:)];

  NSLog(@"sending %@ to %@ with '%@'", request.requestMethod, request.url, request.postBody);
  [currentRequests addObject: request];
  [request startAsynchronous];
}

// -------------------------------------------------------------------------------------------
#pragma mark Response handling

- (void) handleFinishedRequest: (ASIHTTPRequest *) request {
  BOOL html = [[request.responseHeaders objectForKey: @"Content-Type"] isEqual: @"text/html; charset=utf-8"];
  NSLog(@"finished request to %@ (text = %@)", request.url, html ? @"<...html...>" : request.responseString);
  [[request retain] autorelease];
  [currentRequests removeObject: request];
}

- (void) authenticationSuccessful: (ASIHTTPRequest *) request {
  [self handleFinishedRequest: request];
  SafeDelegateCall(authenticationSuccessful);
  loggedIn = YES;
}

- (void) dashboardUpdated: (ASIHTTPRequest *) request {
  [self handleFinishedRequest: request];
  NSString *trimmedString = [request.responseString trimmedString];
  if (trimmedString.length > 0) {
    // msgs are coming in the order from newest to oldest
    NSArray *messages = [OBMessage messagesFromJSONString: trimmedString];
    if (messages.count > 0) {
      lastMessageId = [[messages objectAtIndex: 0] messageId];
    }
    SafeDelegateCall(messagesReceived:, messages);
    isSendingDashboardRequest = NO;
  }
}

- (void) messageSent: (ASIHTTPRequest *) request {
  [self handleFinishedRequest: request];
  SafeDelegateCall(messageSent);
}

- (void) requestFailed: (ASIHTTPRequest *) request {
  if (request.error.domain == NSURLErrorDomain && request.error.code == NSURLErrorTimedOut) {
    [self stopMonitoringDashboard];
  }
  SafeDelegateCall(requestFailedWithError:, request.error);
  [currentRequests removeObject: request];
}

- (void) authenticationNeededForRequest: (ASIHTTPRequest *) request {
  SafeDelegateCall(authenticationFailed);
  // TODO: let the user try again and reuse the connection
  [request cancel];
  [currentRequests removeObject: request];
}

// -------------------------------------------------------------------------------------------
#pragma mark Cleaning up

- (void) cancelAllRequests {
  for (ASIHTTPRequest *request in currentRequests) {
    [request cancel];
  }
  [currentRequests removeAllObjects];
}

- (void) dealloc {
  [self cancelAllRequests];
  ReleaseAll(username, password, currentRequests, monitorTimer);
  [super dealloc];
}

@end

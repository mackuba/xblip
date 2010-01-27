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

@interface NSObject (OBConnectorDelegate)
- authenticationFailed;
- requestFailedWithError: (NSError *) error;
@end

@interface OBConnector ()
- (OBRequest *) requestWithPath: (NSString *) path
                         method: (NSString *) method
                           text: (NSString *) text;
@end


@implementation OBConnector

@synthesize username, loggedIn, password;

// -------------------------------------------------------------------------------------------
#pragma mark Initializers

- (id) initWithUsername: (NSString *) aUsername password: (NSString *) aPassword {
  if (self = [super init]) {
    [self setUsername: aUsername password: aPassword];
    lastMessageId = -1;
    loggedIn = NO;
    isSendingDashboardRequest = NO;
    currentRequests = [[NSMutableArray alloc] initWithCapacity: 5];
  }
  return self;
}

- (id) init {
  return [self initWithUsername: nil password: nil];
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
    [[self dashboardRequest] send];
  }
}

// -------------------------------------------------------------------------------------------
#pragma mark Request sending

- (OBRequest *) authenticateRequest {
  OBRequest *request = [self requestWithPath: @"/login" method: @"GET" text: nil];
  [request setDidFinishSelector: @selector(authenticationSuccessful:)];
  return request;
}

- (OBRequest *) dashboardRequest {
  NSString *path = (lastMessageId > 0) ? OBFormat(@"/dashboard/since/%d", lastMessageId) : @"/dashboard";
  OBRequest *request = [self requestWithPath: path method: @"GET" text: nil];
  [request setDidFinishSelector: @selector(dashboardUpdated:)];
  return request;
}

- (OBRequest *) sendMessageRequest: (NSString *) message {
  NSString *content = OBFormat(@"{\"update\": {\"body\": %@}}", [message jsonStringValue]);
  OBRequest *request = [self requestWithPath: @"/updates" method: @"POST" text: content];
  [request setDidFinishSelector: @selector(messageSent:)];
  return request;
}

- (OBRequest *) requestWithPath: (NSString *) path
                         method: (NSString *) method
                           text: (NSString *) text {
  OBRequest *request = [[OBRequest alloc] initWithPath: path method: method text: text];
  [request addBasicAuthenticationHeaderWithUsername: username andPassword: password];
  [request setDelegate: self];
  [request autorelease];
  [currentRequests addObject: request];
  NSLog(@"sending %@ to %@ with '%@'", method, path, text);
  return request;
}

// -------------------------------------------------------------------------------------------
#pragma mark Response handling

- (void) handleFinishedRequest: (id) request {
  BOOL html = [[[request responseHeaders] objectForKey: @"Content-Type"] isEqual: @"text/html; charset=utf-8"];
  NSLog(@"finished request to %@ (text = %@)", [request url], html ? @"<...html...>" : [request responseString]);
  [[request retain] autorelease];
  [currentRequests removeObject: request];
}

- (void) authenticationSuccessful: (id) request {
  [self handleFinishedRequest: request];
  loggedIn = YES;
  [[request target] performSelector: [request action]];
}

- (void) dashboardUpdated: (id) request {
  [self handleFinishedRequest: request];
  NSString *trimmedString = [[request responseString] trimmedString];
  if (trimmedString.length > 0) {
    // msgs are coming in the order from newest to oldest
    NSArray *messages = [OBMessage messagesFromJSONString: trimmedString];
    if (messages.count > 0) {
      lastMessageId = [[messages objectAtIndex: 0] messageId];
    }
    isSendingDashboardRequest = NO;
    [[request target] performSelector: [request action] withObject: messages];
  }
}

- (void) messageSent: (id) request {
  [self handleFinishedRequest: request];
  [[request target] performSelector: [request action]];
}

- (void) requestFailed: (id) request {
  if ([[request error] domain] == NSURLErrorDomain && [[request error] code] == NSURLErrorTimedOut) {
    [self stopMonitoringDashboard];
  }
  [[request target] requestFailedWithError: [request error]];
  [currentRequests removeObject: request];
}

- (void) authenticationNeededForRequest: (id) request {
  // TODO: let the user try again and reuse the connection
  [[request target] authenticationFailed];
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

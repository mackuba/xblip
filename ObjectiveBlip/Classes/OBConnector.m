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
- (void) handleFinishedRequest: (OBRequest *) request;
- (BOOL) isSendingDashboardRequest;
- (void) cancelAllRequests;
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
  if (![self isSendingDashboardRequest]) {
    [self getDashboard];
  }
}

// -------------------------------------------------------------------------------------------
#pragma mark Request sending

- (void) authenticate {
  [self sendRequest: [OBRequest requestForAuthentication]];
}

- (void) getDashboard {
  if (lastMessageId > 0) {
    [self sendRequest: [OBRequest requestForDashboardSince: lastMessageId]];
  } else {
    [self sendRequest: [OBRequest requestForDashboard]];
  }
}

- (BOOL) isSendingDashboardRequest {
  for (OBRequest *request in currentRequests) {
    if (request.type == OBDashboardRequest) {
      return YES;
    }
  }
  return NO;
}

- (void) sendMessage: (NSString *) message {
  [self sendRequest: [OBRequest requestSendingMessage: message]];
}

- (void) sendRequest: (OBRequest *) request {
  [request addBasicAuthenticationHeaderWithUsername: username andPassword: password];
  [request setDelegate: self];
  [request setDidFinishSelector: @selector(requestFinished:)];
  [request setDidFailSelector: @selector(requestFailed:)];

  NSLog(@"sending %@ to %@ (type %d) with '%@'", request.requestMethod, request.url, request.type, request.postBody);
  [currentRequests addObject: request];
  [request startAsynchronous];
}

// -------------------------------------------------------------------------------------------
#pragma mark Response handling

- (void) requestFinished: (ASIHTTPRequest *) asiRequest {
  OBRequest *request = (OBRequest *) asiRequest;
  BOOL html = [[request.responseHeaders objectForKey: @"Content-Type"] isEqual: @"text/html; charset=utf-8"];
  NSLog(@"finished request to %@ (%d) (text = %@)",
    request.url, request.type, html ? @"<...html...>" : request.responseString);
  [self handleFinishedRequest: request];
  [currentRequests removeObject: request];
}

- (void) handleFinishedRequest: (OBRequest *) request {
  NSArray *messages;
  NSString *trimmedString;
  switch (request.type) {
    case OBSendMessageRequest:
      SafeDelegateCall(messageSent);
      break;
    
    case OBDashboardRequest:
      trimmedString = [OBUtils trimmedString: request.responseString];
      if (trimmedString.length > 0) {
        // msgs are coming in the order from newest to oldest
        messages = [OBMessage messagesFromJSONString: trimmedString];
        if (messages.count > 0) {
          lastMessageId = [[messages objectAtIndex: 0] messageId];
        }
        SafeDelegateCall(messagesReceived:, messages);
      }
      break;
    
    case OBAuthenticationRequest:
      SafeDelegateCall(authenticationSuccessful);
      loggedIn = YES;
      break;
  }
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

// -------------------------------------------------------
// OBConnector.m
//
// Copyright (c) 2009 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

#import "NSDataMBBase64.h"
#import "Constants.h"
#import "OBConnector.h"
#import "OBRequest.h"
#import "OBMessage.h"
#import "OBUtils.h"
#import "OBURLConnection.h"

#define ThisRequest() [((OBURLConnection *) connection) request]
#define ConnectionFinished() [currentConnections removeObject: connection]
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
- (NSString *) generateAuthenticationStringFromUsername: (NSString *) username
                                               password: (NSString *) password;
- (void) handleFinishedRequest: (OBRequest *) request;
- (BOOL) isSendingDashboardRequest;
- (void) closeAllConnections;
@end


@implementation OBConnector

@synthesize username, delegate, loggedIn, password, userAgent;

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
    currentConnections = [[NSMutableArray alloc] initWithCapacity: 5];
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
  authenticationString = [self generateAuthenticationStringFromUsername: username
                                                               password: password];
  [authenticationString retain];
}

- (NSString *) generateAuthenticationStringFromUsername: (NSString *) aUsername
                                               password: (NSString *) aPassword {
  if (aUsername && aPassword) {
    NSString *authString = OBFormat(@"%@:%@", aUsername, aPassword);
    NSData *data = [authString dataUsingEncoding: NSUTF8StringEncoding];
    NSString *encoded = OBFormat(@"Basic %@", [data base64Encoding]);
    return encoded;
  } else {
    return nil;
  }
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
  for (OBURLConnection *connection in currentConnections) {
    if (connection.request.type == OBDashboardRequest) {
      return YES;
    }
  }
  return NO;
}

- (void) sendMessage: (NSString *) message {
  [self sendRequest: [OBRequest requestSendingMessage: message]];
}

- (void) sendRequest: (OBRequest *) request {
  NSLog(@"sending %@ to %@ (type %d) with '%@'", request.HTTPMethod, request.URL, request.type, request.sentText);
  [request setValueIfNotEmpty: userAgent forHTTPHeaderField: @"User-Agent"];
  [request setValueIfNotEmpty: authenticationString forHTTPHeaderField: @"Authorization"];
  OBURLConnection *connection = [OBURLConnection connectionWithRequest: request delegate: self];
  [currentConnections addObject: connection];
}

// -------------------------------------------------------------------------------------------
#pragma mark Response handling

- (void) connection: (NSURLConnection *) connection didReceiveResponse: (NSURLResponse *) response {
  ThisRequest().response = response;
}

- (void) connection: (NSURLConnection *) connection didReceiveData: (NSData *) data {
  NSString *receivedText = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
  [ThisRequest() appendReceivedText: receivedText];
  [receivedText release];
}

- (void) connectionDidFinishLoading: (NSURLConnection *) connection {
  NSLog(@"finished request to %@ (%d) (text = %@)", ThisRequest().URL, ThisRequest().type, ThisRequest().receivedText);
  [self handleFinishedRequest: ThisRequest()];
  ConnectionFinished();
}

- (void) handleFinishedRequest: (OBRequest *) request {
  NSArray *messages;
  NSString *trimmedString;
  switch (request.type) {
    case OBSendMessageRequest:
      SafeDelegateCall(messageSent);
      break;
    
    case OBDashboardRequest:
      trimmedString = [OBUtils trimmedString: request.receivedText];
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

- (NSURLRequest *) connection: (NSURLConnection *) connection
              willSendRequest: (NSURLRequest *) nsrequest
             redirectResponse: (NSURLResponse *) response {
  if (response && ThisRequest().type == OBAuthenticationRequest) {
    // here, redirect means we've succesfully authenticated. this is Blip's way of telling us that... :-)
    NSLog(@"auth redirected = OK");
    SafeDelegateCall(authenticationSuccessful);
    ConnectionFinished();
    loggedIn = YES;
    return nil;
  } else {
    return nsrequest;
  }
}

- (void) connection: (NSURLConnection *) connection didFailWithError: (NSError *) error {
  if (error.domain == NSURLErrorDomain && error.code == NSURLErrorTimedOut) {
    [self stopMonitoringDashboard];
  }
  SafeDelegateCall(requestFailedWithError:, error);
  ConnectionFinished();
}

- (void) connection: (NSURLConnection *) connection
         didReceiveAuthenticationChallenge: (NSURLAuthenticationChallenge *) challenge {
  SafeDelegateCall(authenticationFailed);
  // TODO: let the user try again and reuse the connection
  [[challenge sender] cancelAuthenticationChallenge: challenge];
  ConnectionFinished();
}

// -------------------------------------------------------------------------------------------
#pragma mark Cleaning up

- (void) closeAllConnections {
  for (NSURLConnection *connection in currentConnections) {
    [connection cancel];
  }
  [currentConnections removeAllObjects];
}

- (void) dealloc {
  [self closeAllConnections];
  ReleaseAll(username, password, authenticationString, userAgent, currentConnections, monitorTimer);
  [super dealloc];
}

@end

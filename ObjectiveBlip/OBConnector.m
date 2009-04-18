// -------------------------------------------------------------------------------------------
// "THE BEER-WARE LICENSE" (Revision 42):
// Jakub Suder <jakub.suder@gmail.com> wrote this file. As long as you retain this notice
// you can do whatever you want with this stuff. If we meet some day, and you think this
// stuff is worth it, you can buy me a beer in return.
// (License text originally created by Poul-Henning Kamp, http://people.freebsd.org/~phk/)
// -------------------------------------------------------------------------------------------

#import "NSDataMBBase64.h"
#import "Constants.h"
#import "OBConnector.h"
#import "OBRequest.h"
#import "OBMessage.h"
#import "OBUtils.h"
#import "OBURLConnection.h"

#define SetHeader(request, key, value) [request setValue: value forHTTPHeaderField: key]
#define SetHeaderNotEmpty(request, key, value) if (value) [request setValue: value forHTTPHeaderField: key]
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
- (NSMutableURLRequest *) buildNSURLRequestFor: (OBRequest *) request;
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
    NSString *authString = [[NSString alloc] initWithFormat: @"%@:%@", aUsername, aPassword];
    NSData *data = [authString dataUsingEncoding: NSUTF8StringEncoding];
    NSString *encoded = [[NSString alloc] initWithFormat: @"Basic %@", [data base64Encoding]];
    [authString release];
    return [encoded autorelease];
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
  NSMutableURLRequest *nsrequest = [self buildNSURLRequestFor: request];
  NSLog(@"sending request to %@ %@ (type %d) with text '%@'", request.httpMethod, request.path, request.type,
    request.sentText);
  OBURLConnection *connection = [[OBURLConnection alloc] initWithNSURLRequest: nsrequest
                                                                    OBRequest: request
                                                                     delegate: self];
  [currentConnections addObject: connection];
  [connection release];
}

- (NSMutableURLRequest *) buildNSURLRequestFor: (OBRequest *) request {
  NSMutableURLRequest *nsrequest;
  nsrequest = [[NSMutableURLRequest alloc] initWithURL: [request url]
                                           cachePolicy: NSURLRequestReloadIgnoringLocalCacheData
                                           timeoutInterval: 15];
  [nsrequest setHTTPMethod: request.httpMethod];

  SetHeader(nsrequest, @"X-Blip-API", BLIP_API_VERSION);
  SetHeader(nsrequest, @"Accept", @"application/json");
  SetHeaderNotEmpty(nsrequest, @"User-Agent", userAgent);
  SetHeaderNotEmpty(nsrequest, @"Authorization", authenticationString);
  if ([request isSendingText]) {
    SetHeader(nsrequest, @"Content-Type", @"application/json");
    [nsrequest setHTTPBody: [request.sentText dataUsingEncoding: NSUTF8StringEncoding]];
  }

  return [nsrequest autorelease];
}

// -------------------------------------------------------------------------------------------
#pragma mark Response handling

- (void) connection: (NSURLConnection *) connection didReceiveResponse: (NSURLResponse *) response {
  NSLog(@"received response");
  ThisRequest().response = response;
}

- (void) connection: (NSURLConnection *) connection didReceiveData: (NSData *) data {
  NSLog(@"received data");
  NSString *receivedText = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
  [ThisRequest() appendReceivedText: receivedText];
  [receivedText release];
}

- (void) connectionDidFinishLoading: (NSURLConnection *) connection {
  NSLog(@"finished request to %@ (%d) (text = %@)", ThisRequest().path, ThisRequest().type, ThisRequest().receivedText);
  [self handleFinishedRequest: ThisRequest()];
  ConnectionFinished();
}

- (void) handleFinishedRequest: (OBRequest *) request {
  NSArray *messages;
  switch (request.type) {
    case OBSendMessageRequest:
      SafeDelegateCall(messageSent);
      break;
    
    case OBDashboardRequest:
      messages = [OBMessage messagesFromJSONString: request.receivedText];
      if (messages.count > 0) {
        lastMessageId = [[messages objectAtIndex: 0] messageId];
      }
      SafeDelegateCall(messagesReceived:, messages); 
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
  NSLog(@"error");
  if (error.domain == NSURLErrorDomain && error.code == NSURLErrorTimedOut) {
    [self stopMonitoringDashboard];
  }
  SafeDelegateCall(requestFailedWithError:, error);
  ConnectionFinished();
}

- (void) connection: (NSURLConnection *) connection
         didReceiveAuthenticationChallenge: (NSURLAuthenticationChallenge *) challenge {
  NSLog(@"auth plz");
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

// -------------------------------------------------------------------------------------------
// "THE BEER-WARE LICENSE" (Revision 42):
// Jakub Suder <jakub.suder@gmail.com> wrote this file. As long as you retain this notice
// you can do whatever you want with this stuff. If we meet some day, and you think this
// stuff is worth it, you can buy me a beer in return.
// (License text originally created by Poul-Henning Kamp, http://people.freebsd.org/~phk/)
// -------------------------------------------------------------------------------------------

#import "OBConnector.h"
#import "OBRequest.h"
#import "OBMessage.h"
#import "OBURLConnection.h"
#import "NSDataMBBase64.h"
#import "NSDictionary+BSJSONAdditions.h"
#import "NSArray+BSJSONAdditions.h"
#import "OBUtils.h"


// TODO: make classes for updates, users etc.
// TODO: handle requests better - OBConnector should remember which request matches which response
//       and should return more meaningful results, e.g. an NSArray of Messages instead of a JSON string

@interface NSObject (OBConnectorDelegate)
- messageSent;
- messagesReceived: (NSArray *) messages;
- authenticationSuccessful;
- authenticationFailed;
- requestFailedWithError: (NSError *) error;
@end

@interface OBConnector ()
- (void) closeAllConnections;
- (NSString *) generateAuthenticationStringFromUsername: (NSString *) username password: (NSString *) password;
- (NSMutableURLRequest *) buildNSURLRequestFor: (OBRequest *) request;
- (void) handleFinishedRequest: (OBRequest *) request;
@end


@implementation OBConnector

@synthesize username, delegate, loggedIn, password;

- (id) init {
  return [self initWithUsername: nil password: nil delegate: nil];
}

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

- (void) setUsername: (NSString *) aUsername password: (NSString *) aPassword {
  [username autorelease];
  [password autorelease];
  username = [aUsername copy];
  password = [aPassword copy];
  authenticationString = [[self generateAuthenticationStringFromUsername: username password: password] retain];
}

- (NSString *) generateAuthenticationStringFromUsername: (NSString *) aUsername password: (NSString *) aPassword {
  if (aUsername && aPassword) {
    NSString *authString = [[NSString alloc] initWithFormat: @"%@:%@", aUsername, aPassword];
    NSData *data = [authString dataUsingEncoding: NSUTF8StringEncoding];
    NSString *encoded = [[NSString alloc] initWithFormat: @"Basic %@", [data base64Encoding]];
    [authString release];
    return encoded;
  } else {
    return nil;
  }
}

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

- (void) dashboardTimerFired: (NSTimer *) timer {
  [self getDashboard];
  // TODO: do not send a request if another request is still in progress
}

- (void) startMonitoringDashboard {
  [monitorTimer invalidate];
  monitorTimer = [NSTimer scheduledTimerWithTimeInterval: 10
                                                  target: self
                                                selector: @selector(dashboardTimerFired:)
                                                userInfo: nil
                                                 repeats: YES];
  [monitorTimer retain];
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
  
  [nsrequest setValue: BLIP_API_VERSION    forHTTPHeaderField: @"X-Blip-API"];
  [nsrequest setValue: USER_AGENT          forHTTPHeaderField: @"User-Agent"];
  [nsrequest setValue: @"application/json" forHTTPHeaderField: @"Accept"];
  
  if (authenticationString) {
    [nsrequest setValue: authenticationString forHTTPHeaderField: @"Authorization"];
  }
  if ([request sendsText]) {
    [nsrequest setHTTPBody: [request.sentText dataUsingEncoding: NSUTF8StringEncoding]];
    [nsrequest setValue: @"application/json" forHTTPHeaderField: @"Content-Type"];
  }

  return [nsrequest autorelease];
}

- (void) connection: (NSURLConnection *) connection didReceiveResponse: (NSURLResponse *) response {
  NSLog(@"received response");
  OBRequest *request = [((OBURLConnection *) connection) request];
  request.response = response;
}

- (void) connection: (NSURLConnection *) connection didReceiveData: (NSData *) data {
  NSLog(@"received data");
  NSString *receivedText = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
  OBRequest *request = [((OBURLConnection *) connection) request];
  [request appendReceivedText: receivedText];
  [receivedText release];
}

- (void) connectionDidFinishLoading: (NSURLConnection *) connection {
  OBRequest *request = [((OBURLConnection *) connection) request];
  NSLog(@"finished request to %@ (%d) (text = %@)", request.path, request.type, request.receivedText);
  [self handleFinishedRequest: request];
  [currentConnections removeObject: connection];
}

- (void) handleFinishedRequest: (OBRequest *) request {
  NSArray *messages;
  switch (request.type) {
    case OBSendMessageRequest:
      if ([delegate respondsToSelector: @selector(messageSent)]) {
        [delegate messageSent];
      }
      break;
    
    case OBDashboardRequest:
      messages = [OBMessage messagesFromJSON: request.receivedText];
      if (messages.count > 0) {
        lastMessageId = [[messages objectAtIndex: 0] messageId];
      }
      if ([delegate respondsToSelector: @selector(messagesReceived:)]) {
        [delegate messagesReceived: messages];
      }
      break;
    
    case OBAuthenticationRequest:
      if ([delegate respondsToSelector: @selector(authenticationSuccessful)]) {
        [delegate authenticationSuccessful];
      }
      loggedIn = YES;
      break;
  }
}

- (NSURLRequest *) connection: (NSURLConnection *) connection
              willSendRequest: (NSURLRequest *) nsrequest
             redirectResponse: (NSURLResponse *) response {
  if (response) {
    // response was redirected
    OBRequest *request = [((OBURLConnection *) connection) request];
    if (request.type == OBAuthenticationRequest) {
      // here, redirect means we've succesfully authenticated. this is Blip's way of telling us that... :-)
      NSLog(@"auth redirected = OK");
      if ([delegate respondsToSelector: @selector(authenticationSuccessful)]) {
        [delegate authenticationSuccessful];
      }
      loggedIn = YES;
      [currentConnections removeObject: connection];
      return nil;
    } else {
      NSLog(@"something redirected");
      // follow the redirect
      return nsrequest;
    }
  } else {
    NSLog(@"letting it go");
    // it's the request we're just sending, let it go
    return nsrequest;
  }
}

- (void) connection: (NSURLConnection *) connection didFailWithError: (NSError *) error {
  NSLog(@"error");
  if ([delegate respondsToSelector: @selector(requestFailedWithError:)]) {
    // TODO: add more detailed error handling
    [delegate requestFailedWithError: error];
  }
  [currentConnections removeObject: connection];
}

- (void) connection: (NSURLConnection *) connection
didReceiveAuthenticationChallenge: (NSURLAuthenticationChallenge *) challenge {
  NSLog(@"auth plz");
  if ([delegate respondsToSelector: @selector(authenticationFailed)]) {
    [delegate authenticationFailed];
  }
  // TODO: let the user try again and reuse the connection
  [[challenge sender] cancelAuthenticationChallenge: challenge];
  [currentConnections removeObject: connection];
}

- (void) closeAllConnections {
  for (NSURLConnection *connection in currentConnections) {
    [connection cancel];
  }
  [currentConnections removeAllObjects];
}

- (void) dealloc {
  [self closeAllConnections];
  [super dealloc];
}

@end

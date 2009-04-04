// -------------------------------------------------------------------------------------------
// "THE BEER-WARE LICENSE" (Revision 42):
// Jakub Suder <jakub.suder@gmail.com> wrote this file. As long as you retain this notice
// you can do whatever you want with this stuff. If we meet some day, and you think this
// stuff is worth it, you can buy me a beer in return.
// (License text originally created by Poul-Henning Kamp, http://people.freebsd.org/~phk/)
// -------------------------------------------------------------------------------------------

#import "BlipConnection.h"
#import "NSDataMBBase64.h"
#import "NSDictionary+BSJSONAdditions.h"
#import "NSArray+BSJSONAdditions.h"
#import "OBUtils.h"


// TODO: make classes for updates, users etc.
// TODO: handle requests better - BlipConnection should remember which request matches which response
//       and should return more meaningful results, e.g. an NSArray of Messages instead of a JSON string

@interface BlipConnection ()
- (void) sendRequestTo: (NSString *) path;
- (void) sendPostRequestTo: (NSString *) path withText: (NSString *) text;
- (void) sendRequestTo: (NSString *) path
                method: (NSString *) method
              withText: (NSString *) text;
- (void) closeCurrentConnection;
- (NSString *) generateAuthenticationStringFromUsername: (NSString *) username password: (NSString *) password;
@end


@implementation BlipConnection

@synthesize username, delegate, loggedIn;

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
  [self sendRequestTo: @"/login"];
}

- (void) getDashboard {
  NSMutableString *path = [[NSMutableString alloc] initWithString: @"/dashboard"];
  if (lastMessageId > 0) {
    [path appendFormat: @"/since/%d", lastMessageId];
  }
  [self sendRequestTo: path];
  [path release];
}

- (void) dashboardTimerFired: (NSTimer *) timer {
  [self getDashboard];
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
  NSLog(@"sending message: '%@'", message);
  NSDictionary *update = [[NSDictionary alloc] initWithObjectsAndKeys: message, @"body", nil];
  NSDictionary *content = [[NSDictionary alloc] initWithObjectsAndKeys: update, @"update", nil];
  NSLog(@"content string: '%@'", [content jsonStringValue]);
  [self sendPostRequestTo: @"/updates" withText: [content jsonStringValue]];
  [content release];
  [update release];
}

- (void) sendRequestTo: (NSString *) path {
  [self sendRequestTo: path method: @"GET" withText: nil];
}

- (void) sendPostRequestTo: (NSString *) path withText: (NSString *) text {
  [self sendRequestTo: path method: @"POST" withText: text];
}

- (void) sendRequestTo: (NSString *) path
                method: (NSString *) method
              withText: (NSString *) text {
  [self closeCurrentConnection];
  
  NSString *urlString = [BLIP_API_HOST stringByAppendingString: path];
  NSLog(@"connecting to: %@", urlString);
  NSURL *url = [[NSURL alloc] initWithString: urlString];

  // TODO: shouldn't I use NSURLRequestReloadIgnoringLocalAndRemoteCacheData ?
  NSMutableURLRequest *request;
  request = [[NSMutableURLRequest alloc] initWithURL: url
                                         cachePolicy: NSURLRequestReloadIgnoringLocalCacheData
                                         timeoutInterval: 15];
  [request setHTTPMethod: method];
  [request setValue: BLIP_API_VERSION forHTTPHeaderField: @"X-Blip-API"];
  [request setValue: USER_AGENT forHTTPHeaderField: @"User-Agent"];
  [request setValue: @"application/json" forHTTPHeaderField: @"Accept"];
  if (authenticationString) {
    [request setValue: authenticationString forHTTPHeaderField: @"Authorization"];
  }
  if (text && text.length > 0) {
    [request setHTTPBody: [text dataUsingEncoding: NSUTF8StringEncoding]];
    [request setValue: @"application/json" forHTTPHeaderField: @"Content-Type"];
  }

  currentConnection = [[NSURLConnection alloc] initWithRequest: request delegate: self];
  if (currentText) {
    [currentText setString: @""];
  } else {
    currentText = [[NSMutableString alloc] init];
  }

  [request release];
  [url release];
}

- (void) connection: (NSURLConnection *) connection didReceiveResponse: (NSURLResponse *) response {
  NSLog(@"received response");
  [currentResponse release];
  currentResponse = [response retain];
}

- (void) connection: (NSURLConnection *) connection didReceiveData: (NSData *) data {
  NSLog(@"received data");
  NSString *receivedText = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
  [currentText appendString: receivedText];
  [receivedText release];
}

- (void) connectionDidFinishLoading: (NSURLConnection *) connection {
  NSLog(@"finished");
  NSString *trimmed = [OBUtils trimmedString: currentText];
  if ([OBUtils string: trimmed startsWithCharacter: '[']) {
    NSArray *messages = [NSArray arrayWithJSONString: trimmed];
    if (messages.count > 0) {
      lastMessageId = [[[messages objectAtIndex: 0] objectForKey: @"id"] intValue];
    }
  }
  if ([delegate respondsToSelector: @selector(requestFinishedWithResponse:text:)]) {
    [delegate requestFinishedWithResponse: currentResponse text: currentText];
  }
  [currentResponse release];
  currentResponse = nil;
}

- (NSURLRequest *) connection: (NSURLConnection *) connection
              willSendRequest: (NSURLRequest *) request
             redirectResponse: (NSURLResponse *) response {
  if (response) {
    // don't follow redirects - just let the delegate know
    NSLog(@"redirect");
    if ([delegate respondsToSelector: @selector(requestRedirected)]) {
      [delegate requestRedirected];
    }
    return nil;
  } else {
    // it's the request we're just sending, let it go
    return request;
  }
}

- (void) connection: (NSURLConnection *) connection didFailWithError: (NSError *) error {
  NSLog(@"error");
  if ([delegate respondsToSelector: @selector(requestFailedWithError:)]) {
    [delegate requestFailedWithError: error];
  }
}

- (void) connection: (NSURLConnection *) connection
didReceiveAuthenticationChallenge: (NSURLAuthenticationChallenge *) challenge {
  NSLog(@"auth plz");
  // TODO: get rid of warnings on delegate methods
  if ([delegate respondsToSelector: @selector(authenticationRequired:)]) {
    [delegate authenticationRequired: challenge];
  }
}

- (void) closeCurrentConnection {
  [currentConnection cancel];
  [currentConnection release];
  currentConnection = nil;
}

- (void) dealloc {
  [self closeCurrentConnection];
  [super dealloc];
}

@end

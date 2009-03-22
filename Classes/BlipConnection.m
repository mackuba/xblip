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

@synthesize username;

- (id) initWithUsername: (NSString *) aUsername
               password: (NSString *) aPassword
               delegate: (id) aDelegate {
  self = [super init];
  if (self) {
    username = [aUsername copy];
    password = [aPassword copy];
    delegate = [aDelegate retain];
    authenticationString = [[self generateAuthenticationStringFromUsername: username password: password] retain];
    lastMessageId = -1;
  }
  return self;
}

- (NSString *) generateAuthenticationStringFromUsername: (NSString *) aUsername password: (NSString *) aPassword {
  NSString *authString = [[NSString alloc] initWithFormat: @"%@:%@", aUsername, aPassword];
  NSData *data = [authString dataUsingEncoding: NSUTF8StringEncoding];
  NSString *encoded = [[NSString alloc] initWithFormat: @"Basic %@", [data base64Encoding]];
  [authString release];
  return encoded;
}

- (void) getDashboard {
  NSMutableString *path = [[NSMutableString alloc] initWithString: @"/dashboard"];
  if (lastMessageId > 0) {
    [path appendFormat: @"/since/%d", lastMessageId];
  }
  [self sendRequestTo: path];
  [path release];
}

- (void) sendMessage: (NSString *) message {
  // TODO: make classes for updates, users etc.
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
  [request setValue: BLIP_API_VERSION forHTTPHeaderField: @"X-Blip-API"];
  [request setValue: USER_AGENT forHTTPHeaderField: @"User-Agent"];
  [request setValue: @"application/json" forHTTPHeaderField: @"Accept"];
  [request setValue: authenticationString forHTTPHeaderField: @"Authorization"];
  [request setHTTPMethod: method];
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
  if ([delegate respondsToSelector: @selector(requestFinishedWithResponse:text:)]) {
    [delegate requestFinishedWithResponse: currentResponse text: currentText];
  }
  [currentResponse release];
  currentResponse = nil;
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
  if ([delegate respondsToSelector: @selector(authenticationRequired)]) {
    [delegate authenticationRequired];
  }
}

- (void) closeCurrentConnection {
  [currentConnection cancel];
  [currentConnection release];
  currentConnection = nil;
}

- (void) dealloc {
  [self closeCurrentConnection];
  [delegate release];
  [super dealloc];
}

@end

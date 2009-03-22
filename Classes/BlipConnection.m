// ---------------------------------------------------------------------------------------
// Copyright by Jakub Suder (2009)
//
// xBlip is free software: you can redistribute it and/or modify it under the terms of the
// GNU General Public License as published by the Free Software Foundation, either version
// 2 of the License, or (at your option) any later version.
// ---------------------------------------------------------------------------------------

#import "BlipConnection.h"
#import "NSDataMBBase64.h"

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
  // TODO: use JSON encoding function
  NSLog(@"sending message: '%@'", message);
  NSString *content = [[NSString alloc] initWithFormat: @"{\"update\": {\"body\": \"%@\"}}", message];
  [self sendPostRequestTo: @"/updates" withText: content];
  [content release];
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

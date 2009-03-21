// ---------------------------------------------------------------------------------------
// Copyright by Jakub Suder (2009)
//
// xBlip is free software: you can redistribute it and/or modify it under the terms of the
// GNU General Public License as published by the Free Software Foundation, either version
// 2 of the License, or (at your option) any later version.
// ---------------------------------------------------------------------------------------

// TODO: extract blip connection stuff to a framework?

#import <Foundation/Foundation.h>

#define BLIP_API_HOST @"http://api.blip.pl"
#define BLIP_API_VERSION @"0.02"
#define USER_AGENT @"xBlip/0.1"
// TODO: get app version from configuration

@interface BlipConnection : NSObject {
  NSString *username;
  NSString *password;
  NSString *authenticationString;
  id delegate;
  NSInteger lastMessageId;
  NSURLConnection *currentConnection;
  NSURLResponse *currentResponse;
  NSMutableString *currentText;
}

- (id) initWithUsername: (NSString *) username
               password: (NSString *) password
               delegate: (id) delegate;

- (void) getDashboard;

@end

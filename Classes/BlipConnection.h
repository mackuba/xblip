//
//  BlipConnection.h
//  XBlip
//
//  Created by Jakub Suder on 21-03-09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

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

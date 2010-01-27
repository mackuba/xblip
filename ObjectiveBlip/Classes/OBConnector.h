// -------------------------------------------------------
// OBConnector.h
//
// Copyright (c) 2009 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

#import <Foundation/Foundation.h>

@class OBRequest;

@interface OBConnector : NSObject {
  __weak id delegate;
  BOOL loggedIn;
  NSString *username;
  NSString *password;
  NSInteger lastMessageId;
  NSMutableArray *currentRequests;
  NSTimer *monitorTimer;
}

@property (nonatomic) BOOL loggedIn;
@property (nonatomic, retain) id delegate;
@property (nonatomic, readonly) NSString *username;
@property (nonatomic, readonly) NSString *password;

- (id) init;
- (id) initWithUsername: (NSString *) username
               password: (NSString *) password
               delegate: (id) delegate;

- (void) authenticate;
- (void) getDashboard;
- (void) startMonitoringDashboard;
- (void) stopMonitoringDashboard;
- (void) sendMessage: (NSString *) message;
- (void) sendRequest: (OBRequest *) request;
- (void) setUsername: (NSString *) aUsername password: (NSString *) aPassword;

@end

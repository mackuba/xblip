// -------------------------------------------------------
// OBConnector.h
//
// Copyright (c) 2009 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

#import <Foundation/Foundation.h>

@class OBRequest;

@interface OBConnector : NSObject {
  BOOL loggedIn;
  BOOL isSendingDashboardRequest;
  NSString *username;
  NSString *password;
  NSInteger lastMessageId;
  NSMutableArray *currentRequests;
  NSTimer *monitorTimer;
}

@property (nonatomic) BOOL loggedIn;
@property (nonatomic, readonly) NSString *username;
@property (nonatomic, readonly) NSString *password;

- (id) init;
- (id) initWithUsername: (NSString *) username password: (NSString *) password;

- (OBRequest *) authenticateRequest;
- (OBRequest *) dashboardRequest;
- (OBRequest *) sendMessageRequest: (NSString *) message;

- (void) startMonitoringDashboard;
- (void) stopMonitoringDashboard;
- (void) setUsername: (NSString *) aUsername password: (NSString *) aPassword;

@end

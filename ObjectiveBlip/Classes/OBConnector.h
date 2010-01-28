// -------------------------------------------------------
// OBConnector.h
//
// Copyright (c) 2009 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

#import <Foundation/Foundation.h>

@class OBRequest;

// these callback methods will be called on objects that created the request
@interface NSObject (OBConnectorDelegate)
- (void) authenticationSuccessful;
- (void) authenticationFailed;
- (void) messageSent;
- (void) dashboardUpdatedWithMessages: (NSArray *) messages;
- (void) requestFailedWithError: (NSError *) error;
@end

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
@property (nonatomic, copy) NSString *username;
@property (nonatomic, copy) NSString *password;

- (id) init;
- (id) initWithUsername: (NSString *) username password: (NSString *) password;

- (OBRequest *) authenticateRequest;
- (OBRequest *) dashboardRequest;
- (OBRequest *) sendMessageRequest: (NSString *) message;

- (void) startMonitoringDashboard;
- (void) stopMonitoringDashboard;

@end

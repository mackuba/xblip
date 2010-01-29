// -------------------------------------------------------
// OBConnector.h
//
// Copyright (c) 2009 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

#import <Foundation/Foundation.h>

@class OBRequest;
@class OBDashboardMonitor;

// these callback methods will be called on objects that created the request
@protocol OBConnectorDelegate
- (void) authenticationSuccessful;
- (void) authenticationFailed;
- (void) messageSent;
- (void) dashboardUpdatedWithMessages: (NSArray *) messages;
- (void) requestFailedWithError: (NSError *) error;
@end

@interface OBConnector : NSObject {
  BOOL loggedIn;
  NSString *username;
  NSString *password;
  NSInteger lastMessageId;
  NSMutableArray *currentRequests;
  OBDashboardMonitor *dashboardMonitor;
}

@property (nonatomic) BOOL loggedIn;
@property (nonatomic, copy) NSString *username;
@property (nonatomic, copy) NSString *password;
@property (nonatomic, readonly) OBDashboardMonitor *dashboardMonitor;

- (id) init;
- (id) initWithUsername: (NSString *) username password: (NSString *) password;

- (OBRequest *) authenticateRequest;
- (OBRequest *) dashboardRequest;
- (OBRequest *) sendMessageRequest: (NSString *) message;

@end

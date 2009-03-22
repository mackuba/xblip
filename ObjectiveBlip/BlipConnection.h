// -------------------------------------------------------------------------------------------
// "THE BEER-WARE LICENSE" (Revision 42):
// Jakub Suder <jakub.suder@gmail.com> wrote this file. As long as you retain this notice
// you can do whatever you want with this stuff. If we meet some day, and you think this
// stuff is worth it, you can buy me a beer in return.
// (License text originally created by Poul-Henning Kamp, http://people.freebsd.org/~phk/)
// -------------------------------------------------------------------------------------------

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
  NSTimer *monitorTimer;
}

@property (nonatomic, copy, readonly) NSString *username;
@property (nonatomic, retain) id delegate;

- (id) init;
- (id) initWithUsername: (NSString *) username
               password: (NSString *) password
               delegate: (id) delegate;

- (void) getDashboard;
- (void) startMonitoringDashboard;
- (void) sendMessage: (NSString *) message;

@end

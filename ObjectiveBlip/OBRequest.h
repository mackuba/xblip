// -------------------------------------------------------------------------------------------
// "THE BEER-WARE LICENSE" (Revision 42):
// Jakub Suder <jakub.suder@gmail.com> wrote this file. As long as you retain this notice
// you can do whatever you want with this stuff. If we meet some day, and you think this
// stuff is worth it, you can buy me a beer in return.
// (License text originally created by Poul-Henning Kamp, http://people.freebsd.org/~phk/)
// -------------------------------------------------------------------------------------------

#import <Foundation/Foundation.h>

typedef enum {
  OBDashboardRequest = 1,
  OBSendMessageRequest,
  OBAuthenticationRequest
} OBRequestType;

@interface OBRequest : NSObject {
  NSString *path;
  NSString *httpMethod;
  NSString *sentText;
  OBRequestType type;
  NSURLResponse *response;
  NSMutableString *receivedText;
}

@property (nonatomic, copy) NSString *path;
@property (nonatomic, copy) NSString *httpMethod;
@property (nonatomic, copy) NSString *sentText;
@property (nonatomic) OBRequestType type;
@property (nonatomic, retain) NSURLResponse *response;
@property (nonatomic, readonly) NSMutableString *receivedText;

+ (OBRequest *) requestSendingMessage: (NSString *) message;
+ (OBRequest *) requestForDashboard;
+ (OBRequest *) requestForDashboardSince: (NSInteger) lastMessageId;
+ (OBRequest *) requestForAuthentication;

- (id) initWithPath: (NSString *) path
             method: (NSString *) method
               text: (NSString *) text
               type: (OBRequestType) type;

- (id) initWithPath: (NSString *) path
             method: (NSString *) method
               type: (OBRequestType) type;

- (id) initWithPath: (NSString *) path
               type: (OBRequestType) type;

- (BOOL) sendsText;
- (NSURL *) url;
- (void) appendReceivedText: (NSString *) text;

@end

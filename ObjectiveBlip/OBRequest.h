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

@interface OBRequest : NSMutableURLRequest {
  OBRequestType type;
  NSURLResponse *response;
  NSString *sentText;
  NSMutableString *receivedText;
}

@property (nonatomic) OBRequestType type;
@property (nonatomic, retain) NSURLResponse *response;
@property (nonatomic, readonly) NSString *sentText;
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

- (void) appendReceivedText: (NSString *) text;
- (void) setValueIfNotEmpty: (NSString *) value forHTTPHeaderField: (NSString *) field;

@end

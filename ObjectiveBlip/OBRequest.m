// -------------------------------------------------------------------------------------------
// "THE BEER-WARE LICENSE" (Revision 42):
// Jakub Suder <jakub.suder@gmail.com> wrote this file. As long as you retain this notice
// you can do whatever you want with this stuff. If we meet some day, and you think this
// stuff is worth it, you can buy me a beer in return.
// (License text originally created by Poul-Henning Kamp, http://people.freebsd.org/~phk/)
// -------------------------------------------------------------------------------------------

#import "NSString+BSJSONAdditions.h"
#import "Constants.h"
#import "OBRequest.h"

@implementation OBRequest

@synthesize path, httpMethod, sentText, type, response, receivedText;

// -------------------------------------------------------------------------------------------
#pragma mark Initializers

- (id) initWithPath: (NSString *) _path
             method: (NSString *) _method
               text: (NSString *) _text
               type: (OBRequestType) _type {
  if (self = [super init]) {
    self.path = _path;
    self.type = _type;
    self.httpMethod = _method;
    self.sentText = _text;
    receivedText = [[NSMutableString alloc] init];
  }
  return self;
}

- (id) initWithPath: (NSString *) _path
             method: (NSString *) _method
               type: (OBRequestType) _type {
  return [self initWithPath: _path method: _method text: @"" type: _type];
}

- (id) initWithPath: (NSString *) _path
               type: (OBRequestType) _type {
  return [self initWithPath: _path method: @"GET" text: @"" type: _type];
}

// -------------------------------------------------------------------------------------------
#pragma mark Request generators

+ (OBRequest *) requestSendingMessage: (NSString *) message {
  NSLog(@"sending message: '%@'", message);
  NSString *content = [NSString stringWithFormat: @"{update: {body: %@}}", [message jsonStringValue]];
  NSLog(@"content string: '%@'", content);

  OBRequest *request = [[OBRequest alloc] initWithPath: @"/updates"
                                                method: @"POST"
                                                  text: content
                                                  type: OBSendMessageRequest];
  return [request autorelease];
}

+ (OBRequest *) requestForDashboard {
  return [[OBRequest alloc] initWithPath: @"/dashboard" type: OBDashboardRequest];
}

+ (OBRequest *) requestForDashboardSince: (NSInteger) lastMessageId {
  NSString *path = [NSString stringWithFormat: @"/dashboard/since/%d", lastMessageId];
  return [[OBRequest alloc] initWithPath: path type: OBDashboardRequest];
}

+ (OBRequest *) requestForAuthentication {
  return [[OBRequest alloc] initWithPath: @"/login" type: OBAuthenticationRequest];
}

// -------------------------------------------------------------------------------------------
#pragma mark Instance methods

- (BOOL) isSendingText {
  return (sentText && sentText.length > 0);
}

- (NSURL *) url {
  NSString *urlString = [BLIP_API_HOST stringByAppendingString: path];
  return [NSURL URLWithString: urlString];
}

- (void) appendReceivedText: (NSString *) text {
  [receivedText appendString: text];
}

// -------------------------------------------------------------------------------------------
#pragma mark Cleaning up

- (void) dealloc {
  [path release];
  [httpMethod release];
  [sentText release];
  [response release];
  [receivedText release];
  [super dealloc];
}

@end

// -------------------------------------------------------------------------------------------
// "THE BEER-WARE LICENSE" (Revision 42):
// Jakub Suder <jakub.suder@gmail.com> wrote this file. As long as you retain this notice
// you can do whatever you want with this stuff. If we meet some day, and you think this
// stuff is worth it, you can buy me a beer in return.
// (License text originally created by Poul-Henning Kamp, http://people.freebsd.org/~phk/)
// -------------------------------------------------------------------------------------------

#import <Foundation/Foundation.h>

@class OBRequest;

@interface OBURLConnection : NSURLConnection {
  OBRequest *request;
}

@property (nonatomic, retain) OBRequest *request;

+ (OBURLConnection *) connectionWithRequest: (OBRequest *) request delegate: (id) delegate;
- (id) initWithRequest: (OBRequest *) request delegate: (id) delegate;

@end

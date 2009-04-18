// -------------------------------------------------------------------------------------------
// "THE BEER-WARE LICENSE" (Revision 42):
// Jakub Suder <jakub.suder@gmail.com> wrote this file. As long as you retain this notice
// you can do whatever you want with this stuff. If we meet some day, and you think this
// stuff is worth it, you can buy me a beer in return.
// (License text originally created by Poul-Henning Kamp, http://people.freebsd.org/~phk/)
// -------------------------------------------------------------------------------------------

#import "OBURLConnection.h"
#import "OBRequest.h"
#import "OBUtils.h"

@implementation OBURLConnection

SynthesizeAndReleaseLater(request);

- (id) initWithNSURLRequest: (NSURLRequest *) nsrequest
                  OBRequest: (OBRequest *) obrequest
                   delegate: (id) delegate {
  if (self = [super initWithRequest: nsrequest delegate: delegate]) {
    self.request = obrequest;
  }
  return self;
};

@end

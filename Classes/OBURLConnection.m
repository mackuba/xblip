// -------------------------------------------------------
// OBURLConnection.m
//
// Copyright (c) 2009 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

#import "OBURLConnection.h"
#import "OBRequest.h"
#import "OBUtils.h"

@implementation OBURLConnection

SynthesizeAndReleaseLater(request);

+ (OBURLConnection *) connectionWithRequest: (OBRequest *) request delegate: (id) delegate {
  return [[[OBURLConnection alloc] initWithRequest: request delegate: delegate] autorelease];
};

- (id) initWithRequest: (OBRequest *) obrequest delegate: (id) delegate {
  if (self = [super initWithRequest: obrequest delegate: delegate]) {
    self.request = obrequest;
  }
  return self;
};

@end

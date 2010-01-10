// -------------------------------------------------------
// OBURLConnection.h
//
// Copyright (c) 2009 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

#import <Foundation/Foundation.h>

@class OBRequest;

@interface OBURLConnection : NSURLConnection {
  OBRequest *request;
}

@property (nonatomic, retain) OBRequest *request;

+ (OBURLConnection *) connectionWithRequest: (OBRequest *) request delegate: (id) delegate;
- (id) initWithRequest: (OBRequest *) request delegate: (id) delegate;

@end

// -------------------------------------------------------
// OBRequest.h
//
// Copyright (c) 2009 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

#import <Foundation/Foundation.h>
#import "ASIHTTPRequest.h"

@interface OBRequest : ASIHTTPRequest {
  id target;
  SEL action;
}

@property (nonatomic, readonly) id target;
@property (nonatomic, readonly) SEL action;

- (id) initWithPath: (NSString *) path
             method: (NSString *) method
               text: (NSString *) text;

- (void) sendFor: (id) target
       onSuccess: (SEL) action;

- (void) send;

@end

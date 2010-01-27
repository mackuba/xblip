// -------------------------------------------------------
// OBRequest.h
//
// Copyright (c) 2009 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

#import <Foundation/Foundation.h>
#import "ASIHTTPRequest.h"

@interface OBRequest : ASIHTTPRequest {}

+ (OBRequest *) requestWithPath: (NSString *) path
                         method: (NSString *) method
                           text: (NSString *) text;

- (id) initWithPath: (NSString *) path
             method: (NSString *) method
               text: (NSString *) text;

@end

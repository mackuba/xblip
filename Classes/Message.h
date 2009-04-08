// ---------------------------------------------------------------------------------------
// Copyright by Jakub Suder (2009)
//
// xBlip is free software: you can redistribute it and/or modify it under the terms of the
// GNU General Public License as published by the Free Software Foundation, either version
// 2 of the License, or (at your option) any later version.
// ---------------------------------------------------------------------------------------

#import <Foundation/Foundation.h>

@interface Message : NSObject {
  NSString *username;
  NSString *content;
}

@property (nonatomic, copy) NSString *username;
@property (nonatomic, copy) NSString *content;

@end
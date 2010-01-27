// -------------------------------------------------------
// OBUtils.m
//
// Copyright (c) 2009 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

#import "OBUtils.h"

@implementation NSString (OBUtils)

- (NSString *) trimmedString {
  NSCharacterSet *whitespace = [NSCharacterSet whitespaceAndNewlineCharacterSet];
  return [self stringByTrimmingCharactersInSet: whitespace];
}

@end

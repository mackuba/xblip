// -------------------------------------------------------
// OBUtils.m
//
// Copyright (c) 2009 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

#import "OBUtils.h"

@implementation OBUtils

+ (NSString *) trimmedString: (NSString*) originalString {
  NSCharacterSet *whitespace = [NSCharacterSet whitespaceAndNewlineCharacterSet];
  return [originalString stringByTrimmingCharactersInSet: whitespace];
}

@end

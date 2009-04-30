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

/*+ (BOOL) string: (NSString *) string startsWithCharacter: (unichar) character {
  return (string.length > 0 && [string characterAtIndex: 0] == character);
} */

@end

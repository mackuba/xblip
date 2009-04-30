// -------------------------------------------------------
// OBUtils.h
//
// Copyright (c) 2009 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

#import <Foundation/Foundation.h>

#define ReleaseAll(...) \
  NSArray *_releaseList = [[NSArray alloc] initWithObjects: __VA_ARGS__, nil]; \
  for (NSObject *object in _releaseList) { \
    [object release]; \
  } \
  [_releaseList release];

#define OnDeallocRelease(...) \
  - (void) dealloc { \
    ReleaseAll(__VA_ARGS__); \
    [super dealloc]; \
  }

#define SynthesizeAndReleaseLater(...) \
  @synthesize __VA_ARGS__; \
  OnDeallocRelease(__VA_ARGS__);

#define OBArray(...) [NSArray arrayWithObjects: __VA_ARGS__, nil]
#define OBDict(...) [NSDictionary dictionaryWithObjectsAndKeys: __VA_ARGS__, nil]
#define OBFormat(...) [NSString stringWithFormat: __VA_ARGS__]

@interface OBUtils : NSObject

+ (NSString *) trimmedString: (NSString*) string;
// + (BOOL) string: (NSString *) string startsWithCharacter: (unichar) character;

@end

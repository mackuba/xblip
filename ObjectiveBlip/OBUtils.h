// -------------------------------------------------------------------------------------------
// "THE BEER-WARE LICENSE" (Revision 42):
// Jakub Suder <jakub.suder@gmail.com> wrote this file. As long as you retain this notice
// you can do whatever you want with this stuff. If we meet some day, and you think this
// stuff is worth it, you can buy me a beer in return.
// (License text originally created by Poul-Henning Kamp, http://people.freebsd.org/~phk/)
// -------------------------------------------------------------------------------------------

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

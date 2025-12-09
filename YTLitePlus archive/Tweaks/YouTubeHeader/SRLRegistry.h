#import <Foundation/NSObject.h>

struct _SRLAPIRegistrationData {
    char *name;
    // ...
};

struct SRLScopeTagSet {
    void *_field1[4];
};

@interface SRLRegistry : NSObject
- (id)internalService:(struct _SRLAPIRegistrationData *)service scopeTags:(struct SRLScopeTagSet)tags;
@end

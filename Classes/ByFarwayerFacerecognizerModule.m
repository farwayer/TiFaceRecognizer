#import "ByFarwayerFacerecognizerModule.h"

@implementation ByFarwayerFacerecognizerModule

#pragma mark Internal

- (id)moduleGUID {
    return @"7f26aa9a-c034-40ec-92fc-d176383a57e3";
}

- (NSString *)moduleId {
    return @"by.farwayer.facerecognizer";
}

#pragma mark Lifecycle

- (void)startup {
    [super startup];

    NSLog(@"[INFO] %@ loaded", [self moduleId]);
}

- (void)shutdown:(id)sender {

    [super shutdown:sender];
}

#pragma mark Cleanup 

- (void)dealloc {
    [super dealloc];
}

MAKE_SYSTEM_STR(ACCURACY_LOW, CIDetectorAccuracyLow);
MAKE_SYSTEM_STR(ACCURACY_HIGH, CIDetectorAccuracyHigh);

MAKE_SYSTEM_UINT(IMAGE_ORIENTATION_TOP_LEFT, 1)
MAKE_SYSTEM_UINT(IMAGE_ORIENTATION_TOP_RIGHT, 2)
MAKE_SYSTEM_UINT(IMAGE_ORIENTATION_BOTTOM_RIGHT, 3)
MAKE_SYSTEM_UINT(IMAGE_ORIENTATION_BOTTOM_LEFT, 4)
MAKE_SYSTEM_UINT(IMAGE_ORIENTATION_LEFT_TOP, 5)
MAKE_SYSTEM_UINT(IMAGE_ORIENTATION_RIGHT_TOP, 6)
MAKE_SYSTEM_UINT(IMAGE_ORIENTATION_RIGHT_BOTTOM, 7)
MAKE_SYSTEM_UINT(IMAGE_ORIENTATION_LEFT_BOTTOM, 8)

@end

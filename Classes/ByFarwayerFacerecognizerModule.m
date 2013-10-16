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

@end

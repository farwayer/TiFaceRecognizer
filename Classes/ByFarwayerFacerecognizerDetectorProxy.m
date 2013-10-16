#import <TiUtils.h>
#import "ByFarwayerFacerecognizerDetectorProxy.h"

@interface ByFarwayerFacerecognizerDetectorProxy ()
@property(nonatomic, retain) CIDetector *detector;
@end

@implementation ByFarwayerFacerecognizerDetectorProxy {
}

- (void)createDetector {
    NSString *accuracy = [TiUtils stringValue:@"accuracy" properties:self.allProperties def:CIDetectorAccuracyHigh];
    BOOL tracking = [TiUtils boolValue:@"tracking" properties:self.allProperties def:NO];
    float minFeatureSize = [TiUtils floatValue:@"minFeatureSize" properties:self.allProperties def:1.0];

    self.detector = [CIDetector detectorOfType:CIDetectorTypeFace context:nil options:@{
            CIDetectorAccuracy : accuracy,
            CIDetectorTracking : @(tracking),
            CIDetectorMinFeatureSize : @(minFeatureSize)
    }];
}

- (void)setAccuracy:(id)value {
    ENSURE_SINGLE_ARG(value, NSString);
    [self replaceValue:value forKey:@"accuracy" notification:NO];

    if (self.detector) [self createDetector];
}

- (void)setTracking:(id)value {
    ENSURE_SINGLE_ARG(value, NSNumber);
    [self replaceValue:value forKey:@"tracking" notification:NO];

    if (self.detector) [self createDetector];
}

- (void)setMinFeatureSize:(id)value {
    ENSURE_SINGLE_ARG(value, NSNumber);
    [self replaceValue:value forKey:@"minFeatureSize" notification:NO];

    if (self.detector) [self createDetector];
}

- (void)dealloc {
    self.detector = nil;
    [super dealloc];
}

@end
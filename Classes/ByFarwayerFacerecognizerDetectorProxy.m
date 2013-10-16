#import <TiUtils.h>
#import <TiRect.h>
#import <TiPoint.h>
#import "ByFarwayerFacerecognizerDetectorProxy.h"

@interface ByFarwayerFacerecognizerDetectorProxy ()
@property(nonatomic, retain) CIDetector *detector;
@end

@implementation ByFarwayerFacerecognizerDetectorProxy

- (void)createDetector {
    NSString *accuracy = [TiUtils stringValue:@"accuracy" properties:self.allProperties def:CIDetectorAccuracyHigh];
    BOOL tracking = [TiUtils boolValue:@"tracking" properties:self.allProperties def:NO];
    float minFeatureSize = [TiUtils floatValue:@"minFeatureSize" properties:self.allProperties def:0.0];

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

- (id)featuresInImage:(id)args {
    NSDictionary *options;
    ENSURE_ARG_COUNT(args, 1);
    ENSURE_ARG_OR_NIL_AT_INDEX(options, args, 1, NSDictionary);

    UIImage *image = [TiUtils toImage:args[0] proxy:self];
    if (!image) return nil;

    CIImage *ciImage = image.CIImage? image.CIImage : [CIImage imageWithCGImage:image.CGImage];
    if (!ciImage) return nil;

    if (!self.detector) [self createDetector];

    NSArray *features;
    if (options) {
        int orientation = [TiUtils intValue:@"imageOrientation" properties:options def:1];
        BOOL eyeBlink = [TiUtils boolValue:@"recognizeEyeBlink" properties:options def:NO];
        BOOL smile = [TiUtils boolValue:@"recognizeSmile" properties:options def:NO];

        features = [self.detector featuresInImage:ciImage options:@{
                CIDetectorImageOrientation : @(orientation),
                CIDetectorEyeBlink : @(eyeBlink),
                CIDetectorSmile : @(smile)
        }];
    } else {
        features = [self.detector featuresInImage:ciImage];
    }

    NSMutableArray *faces = [NSMutableArray array];
    for (CIFaceFeature *feature in features) {
        NSMutableDictionary *face = [NSMutableDictionary dictionary];

        TiRect *bounds = [[TiRect alloc] init];
        [bounds setRect:feature.bounds];
        face[@"bounds"] = bounds;

        face[@"hasSmile"] = @(feature.hasSmile);
        face[@"leftEyeClosed"] = @(feature.leftEyeClosed);
        face[@"rightEyeClosed"] = @(feature.rightEyeClosed);

        if (feature.hasLeftEyePosition) {
            face[@"leftEyePosition"] = [[TiPoint alloc] initWithPoint:feature.leftEyePosition];
        }
        if (feature.hasRightEyePosition) {
            face[@"rightEyePosition"] = [[TiPoint alloc] initWithPoint:feature.rightEyePosition];
        }
        if (feature.hasMouthPosition) {
            face[@"mouthPosition"] = [[TiPoint alloc] initWithPoint:feature.mouthPosition];
        }
        if (feature.hasFaceAngle) {
            face[@"faceAngle"] = @(feature.faceAngle);
        }
        if (feature.hasTrackingID) {
            face[@"trackingID"] = @(feature.trackingID);
        }
        if (feature.hasTrackingFrameCount) {
            face[@"trackingFrameCount"] = @(feature.trackingFrameCount);
        }

        [faces addObject:face];
    }

    return @{
            @"success" : NUMBOOL(features.count > 0),
            @"faces": faces
    };
}

@end
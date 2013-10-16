#import <TiUtils.h>
#import <TiRect.h>
#import <TiPoint.h>
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

- (id)featuresInImage:(id)args {
    NSDictionary *options = nil;
    ENSURE_ARG_COUNT(args, 1);
    ENSURE_ARG_AT_INDEX(options, args, 1, NSDictionary);
    UIImage *image = [TiUtils toImage:args[0] proxy:self];
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
        NSMutableDictionary *face = [[NSMutableDictionary alloc] init];

        TiRect *faceRect = [[TiRect alloc] init];
        [faceRect setRect:feature.bounds];
        face[@"position"] = faceRect;
        [faceRect release];

        if (feature.hasLeftEyePosition) {
            TiPoint *leftEye = [[TiPoint alloc] initWithPoint:feature.leftEyePosition];
            face[@"leftEye"] = leftEye;
            [leftEye release];
        }

        if (feature.hasRightEyePosition) {
            TiPoint *rightEye = [[TiPoint alloc] initWithPoint:feature.rightEyePosition];
            face[@"rightEye"] = rightEye;
            [rightEye release];
        }

        if (feature.hasMouthPosition) {
            TiPoint *mouth = [[TiPoint alloc] initWithPoint:feature.mouthPosition];
            face[@"mouth"] = mouth;
            [mouth release];
        }

        [faces addObject:face];
        [face release];
    }

    return features.count > 0? @{
            @"success" : NUMBOOL(YES),
            @"faces": faces
    } : @{
            @"status": NUMBOOL(NO)
    };
}

- (void)dealloc {
    self.detector = nil;
    [super dealloc];
}

@end
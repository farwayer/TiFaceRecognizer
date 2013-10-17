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
    float minFeatureSize = [TiUtils floatValue:@"minFeatureSize" properties:self.allProperties def:0.0100f];

    if (minFeatureSize < 0.0100f || minFeatureSize > 0.5000f) { // REAL range; 0.0-1.0 from Apple docs is invalid
        [self throwException:TiExceptionRangeError
                   subreason:@"minFeatureSize must be from 0.0100 to 0.5000"
                    location:CODELOCATION];
    }

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

- (id)findFeatures:(CIImage *)image recognizeOptions:(NSDictionary *)options {
    if (!self.detector) [self createDetector];

    NSArray *features = options?
            [self.detector featuresInImage:image options:options] :
            [self.detector featuresInImage:image];

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

- (id)featuresInImage:(id)args {
    ENSURE_ARG_COUNT(args, 1);

    id image = args[0];
    NSDictionary *options = VALUE_AT_INDEX_OR_NIL(args, 1);
    ENSURE_TYPE_OR_NIL(options, NSDictionary);
    KrollCallback *callback = VALUE_AT_INDEX_OR_NIL(args, 2);
    ENSURE_TYPE_OR_NIL(callback, KrollCallback);

    UIImage *uiImage = [TiUtils toImage:image proxy:self];
    if (!uiImage) [self throwException:TiExceptionInvalidType subreason:@"invalid image" location:CODELOCATION];

    CIImage *ciImage = uiImage.CIImage? uiImage.CIImage : [CIImage imageWithCGImage:uiImage.CGImage];
    if (!ciImage) [self throwException:TiExceptionInvalidType subreason:@"invalid image" location:CODELOCATION];

    NSDictionary *recognizeOptions = nil;
    if (options) {
        int orientation = [TiUtils intValue:@"imageOrientation" properties:options def:1];
        BOOL eyeBlink = [TiUtils boolValue:@"recognizeEyeBlink" properties:options def:NO];
        BOOL smile = [TiUtils boolValue:@"recognizeSmile" properties:options def:NO];

        recognizeOptions = @{
                CIDetectorImageOrientation : @(orientation),
                CIDetectorEyeBlink : @(eyeBlink),
                CIDetectorSmile : @(smile)
        };
    }

    if (callback) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            id result = [self findFeatures:ciImage recognizeOptions:recognizeOptions];
            [self _fireEventToListener:@"searchResult" withObject:result listener:callback thisObject:self];
        });

        return nil;
    } else {
        return [self findFeatures:ciImage recognizeOptions:recognizeOptions];
    }
}

@end
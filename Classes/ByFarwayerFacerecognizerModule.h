#import <TiModule.h>

@interface ByFarwayerFacerecognizerModule : TiModule {
}

@property (nonatomic, readonly) NSString *ACCURACY_LOW;
@property (nonatomic, readonly) NSString *ACCURACY_HIGH;

@property (nonatomic, readonly) NSNumber *IMAGE_ORIENTATION_TOP_LEFT;
@property (nonatomic, readonly) NSNumber *IMAGE_ORIENTATION_TOP_RIGHT;
@property (nonatomic, readonly) NSNumber *IMAGE_ORIENTATION_BOTTOM_RIGHT;
@property (nonatomic, readonly) NSNumber *IMAGE_ORIENTATION_BOTTOM_LEFT;
@property (nonatomic, readonly) NSNumber *IMAGE_ORIENTATION_LEFT_TOP;
@property (nonatomic, readonly) NSNumber *IMAGE_ORIENTATION_RIGHT_TOP;
@property (nonatomic, readonly) NSNumber *IMAGE_ORIENTATION_RIGHT_BOTTOM;
@property (nonatomic, readonly) NSNumber *IMAGE_ORIENTATION_LEFT_BOTTOM;

@end

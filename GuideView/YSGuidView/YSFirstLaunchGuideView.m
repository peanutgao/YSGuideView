//
//  YSFirstLaunchGuideView.m
//  GuideViewDemo
//
//  Created by Joseph Gao on 16/4/1.
//  Copyright © 2016年 Joseph. All rights reserved.
//

#import "YSFirstLaunchGuideView.h"
#import <Accelerate/Accelerate.h>
#import <float.h>

const CGFloat kDefaultBlurRadius = 1.0;
const CGFloat kDefaultSaturationDeltaFactor = 0.8;

@interface YSFirstLaunchGuideView()

@property (nonatomic, strong) NSArray *imgNames;
@property (nonatomic, strong) UIImageView *blurImgView;
@property (nonatomic, strong) UIImageView *guidImgView;
@property (nonatomic, strong) UIView *bgView;
@property (nonatomic, assign) NSInteger clickedIndex;

@property (nonatomic, assign) CGFloat blurRadius;
@property (nonatomic, assign) CGFloat saturationDeltaFactor;


@end

@implementation YSFirstLaunchGuideView

+ (void)configFirstLaunchWithImgNames:(NSArray *)imgNames
                                  key:(NSString *)key
                           blurRadius:(CGFloat)blurRadius
                saturationDeltaFactor:(CGFloat)saturationDeltaFactor
                               inView:(UIView *)inView {
    NSAssert(key != nil || ![key isEqualToString:@""], @"Key must be not-empty or nil");

    if ([self isFirstLaunchOfKey:key]) {
        if (!imgNames) NSLog(@"=======Images Array is nil !========");

        YSFirstLaunchGuideView *guideView = [[YSFirstLaunchGuideView alloc] initWithImgNames:imgNames
                                                                                  blurRadius:blurRadius
                                                                       saturationDeltaFactor:saturationDeltaFactor
                                                                                      inView:inView];
        [guideView showGuidView];
    }
}


- (instancetype)initWithImgNames:(NSArray *)imgNames
                      blurRadius:(CGFloat)blurRadius
           saturationDeltaFactor:(CGFloat)saturationDeltaFactor
                          inView:(UIView *)inView {
    if (self = [super initWithFrame:[UIScreen mainScreen].bounds]) {
        _blurRadius            = blurRadius;
        _saturationDeltaFactor = saturationDeltaFactor;
        _imgNames              = imgNames;
        _bgView                = inView;
        
        [self setupBlurWithBlurRadius:blurRadius
                saturationDeltaFactor:saturationDeltaFactor];
        [self setupGuidImageView];
    }
    
    return self;
}

- (void)setupBlurWithBlurRadius:(CGFloat)blurRadius
          saturationDeltaFactor:(CGFloat)saturationDeltaFactor {
    _blurImgView = [[UIImageView alloc] initWithFrame:self.bounds];
    [self addSubview:_blurImgView];
    
    // if the param: inView == nil, then do not apply screen snapshot
    if (_bgView == nil) return;
    
    UIImage *viewBgImg = [self getSnapshotOfView:_bgView];
    [self setImageToBlur:viewBgImg
              blurRadius:blurRadius
   saturationDeltaFactor:saturationDeltaFactor];
}

- (void)setupGuidImageView {
    _guidImgView = [[UIImageView alloc] initWithFrame:self.bounds];
    _guidImgView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapGusture = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                 action:@selector(tapGuidImgView:)];
    [_guidImgView addGestureRecognizer:tapGusture];
    [self addSubview:_guidImgView];
    
    [self tapGuidImgView:nil];
}

+ (BOOL)isFirstLaunchOfKey:(NSString *)key {
    NSString *defaultKey = @"firstLaunchInfoDic";
    NSUserDefaults *userDetaults = [NSUserDefaults standardUserDefaults];
    
    NSDictionary *firstLaunchInfoDic = [userDetaults objectForKey:defaultKey];
    if (firstLaunchInfoDic && [firstLaunchInfoDic objectForKey:key]) {
        return NO;
    }
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:firstLaunchInfoDic];
    [dict setValue:@(YES) forKey:key];
    [userDetaults setObject:dict forKey:defaultKey];
    [userDetaults synchronize];

    return YES;
}


#pragma mark - Action

- (void)tapGuidImgView:(UITapGestureRecognizer *)tapGusture {
    if (_clickedIndex >= _imgNames.count) {
        _clickedIndex = 0;
        [self removeFromSuperview];
    }
    
    _guidImgView.image = [UIImage imageNamed:_imgNames[_clickedIndex]];
    _clickedIndex++;
}


- (void)showGuidView {
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    [keyWindow addSubview:self];
}


#pragma mark - Blur Image Method

- (UIImage *)getSnapshotOfView:(UIView *)view {
    UIGraphicsBeginImageContextWithOptions([UIScreen mainScreen].bounds.size, YES, 0);
    
    UIGraphicsBeginImageContextWithOptions(self.frame.size, YES, 0.0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [view.layer renderInContext:context];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
    
    return image;
}


- (void)setImageToBlur:(UIImage *)image
            blurRadius:(CGFloat)blurRadius
 saturationDeltaFactor:(CGFloat)saturationDeltaFactor {
    NSParameterAssert(image);
    
    blurRadius = (blurRadius <= 0) ? kDefaultBlurRadius : blurRadius;
    saturationDeltaFactor = (saturationDeltaFactor <= 0) ? kDefaultSaturationDeltaFactor : saturationDeltaFactor;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        UIImage *bluredImage = [self applyImage:image
                                 blurWithRadius:blurRadius
                                      tintColor:[UIColor colorWithWhite:0.096 alpha:0.800]
                          saturationDeltaFactor:saturationDeltaFactor
                                      maskImage:[UIImage imageNamed:@"1"]];

        dispatch_async(dispatch_get_main_queue(), ^{
            _blurImgView.image = bluredImage;

        });
    });
}

- (UIImage *)applyImage:(UIImage *)originImg
         blurWithRadius:(CGFloat)blurRadius
              tintColor:(UIColor *)tintColor
  saturationDeltaFactor:(CGFloat)saturationDeltaFactor
              maskImage:(UIImage *)maskImage {
    // Check pre-conditions.
    if (originImg.size.width < 1 || originImg.size.height < 1) {
        NSLog (@"*** error: invalid size: (%.2f x %.2f). Both dimensions must be >= 1: %@", originImg.size.width, originImg.size.height, originImg);
        return nil;
    }
    if (!originImg.CGImage) {
        NSLog (@"*** error: image must be backed by a CGImage: %@", self);
        return nil;
    }
    if (maskImage && !maskImage.CGImage) {
        NSLog (@"*** error: maskImage must be backed by a CGImage: %@", maskImage);
        return nil;
    }
    
    CGRect imageRect = { CGPointZero, originImg.size };
    
    UIImage *effectImage = nil;
    
    BOOL hasBlur = blurRadius > __FLT_EPSILON__;
    BOOL hasSaturationChange = fabs(saturationDeltaFactor - 1.) > __FLT_EPSILON__;
    if (hasBlur || hasSaturationChange) {
        UIGraphicsBeginImageContextWithOptions(originImg.size, NO, [[UIScreen mainScreen] scale]);
        CGContextRef effectInContext = UIGraphicsGetCurrentContext();
        CGContextScaleCTM(effectInContext, 1.0, -1.0);
        CGContextTranslateCTM(effectInContext, 0, -originImg.size.height);
        CGContextDrawImage(effectInContext, imageRect, originImg.CGImage);
        
        vImage_Buffer effectInBuffer;
        effectInBuffer.data     = CGBitmapContextGetData(effectInContext);
        effectInBuffer.width    = CGBitmapContextGetWidth(effectInContext);
        effectInBuffer.height   = CGBitmapContextGetHeight(effectInContext);
        effectInBuffer.rowBytes = CGBitmapContextGetBytesPerRow(effectInContext);
        
        UIGraphicsBeginImageContextWithOptions(originImg.size, NO, [[UIScreen mainScreen] scale]);
        CGContextRef effectOutContext = UIGraphicsGetCurrentContext();
        vImage_Buffer effectOutBuffer;
        effectOutBuffer.data     = CGBitmapContextGetData(effectOutContext);
        effectOutBuffer.width    = CGBitmapContextGetWidth(effectOutContext);
        effectOutBuffer.height   = CGBitmapContextGetHeight(effectOutContext);
        effectOutBuffer.rowBytes = CGBitmapContextGetBytesPerRow(effectOutContext);
        
        if (hasBlur) {
            // A description of how to compute the box kernel width from the Gaussian
            // radius (aka standard deviation) appears in the SVG spec:
            // http://www.w3.org/TR/SVG/filters.html#feGaussianBlurElement
            //
            // For larger values of 's' (s >= 2.0), an approximation can be used: Three
            // successive box-blurs build a piece-wise quadratic convolution kernel, which
            // approximates the Gaussian kernel to within roughly 3%.
            //
            // let d = floor(s * 3*sqrt(2*pi)/4 + 0.5)
            //
            // ... if d is odd, use three box-blurs of size 'd', centered on the output pixel.
            //
            CGFloat inputRadius = blurRadius * [[UIScreen mainScreen] scale];
            int radius = floor(inputRadius * 3. * sqrt(2 * M_PI) / 4 + 0.5);
            if (radius % 2 != 1) {
                radius += 1; // force radius to be odd so that the three box-blur methodology works.
            }
            vImageBoxConvolve_ARGB8888(&effectInBuffer, &effectOutBuffer, NULL, 0, 0, radius, radius, 0, kvImageEdgeExtend);
            vImageBoxConvolve_ARGB8888(&effectOutBuffer, &effectInBuffer, NULL, 0, 0, radius, radius, 0, kvImageEdgeExtend);
            vImageBoxConvolve_ARGB8888(&effectInBuffer, &effectOutBuffer, NULL, 0, 0, radius, radius, 0, kvImageEdgeExtend);
        }
        BOOL effectImageBuffersAreSwapped = NO;
        if (hasSaturationChange) {
            CGFloat s = saturationDeltaFactor;
            CGFloat floatingPointSaturationMatrix[] = {
                0.0722 + 0.9278 * s,  0.0722 - 0.0722 * s,  0.0722 - 0.0722 * s,  0,
                0.7152 - 0.7152 * s,  0.7152 + 0.2848 * s,  0.7152 - 0.7152 * s,  0,
                0.2126 - 0.2126 * s,  0.2126 - 0.2126 * s,  0.2126 + 0.7873 * s,  0,
                0,                    0,                    0,  1,
            };
            const int32_t divisor = 256;
            NSUInteger matrixSize = sizeof(floatingPointSaturationMatrix)/sizeof(floatingPointSaturationMatrix[0]);
            int16_t saturationMatrix[matrixSize];
            for (NSUInteger i = 0; i < matrixSize; ++i) {
                saturationMatrix[i] = (int16_t)roundf(floatingPointSaturationMatrix[i] * divisor);
            }
            if (hasBlur) {
                vImageMatrixMultiply_ARGB8888(&effectOutBuffer, &effectInBuffer, saturationMatrix, divisor, NULL, NULL, kvImageNoFlags);
                effectImageBuffersAreSwapped = YES;
            }
            else {
                vImageMatrixMultiply_ARGB8888(&effectInBuffer, &effectOutBuffer, saturationMatrix, divisor, NULL, NULL, kvImageNoFlags);
            }
        }
        if (!effectImageBuffersAreSwapped)
            effectImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        if (effectImageBuffersAreSwapped)
            effectImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    
    // Set up output context.
    UIGraphicsBeginImageContextWithOptions(originImg.size, NO, [[UIScreen mainScreen] scale]);
    CGContextRef outputContext = UIGraphicsGetCurrentContext();
    CGContextScaleCTM(outputContext, 1.0, -1.0);
    CGContextTranslateCTM(outputContext, 0, -originImg.size.height);
    
    // Draw base image.
    CGContextDrawImage(outputContext, imageRect, originImg.CGImage);
    
    // Draw effect image.
    if (hasBlur) {
        CGContextSaveGState(outputContext);
        if (maskImage) {
            CGContextClipToMask(outputContext, imageRect, maskImage.CGImage);
        }
        CGContextDrawImage(outputContext, imageRect, effectImage.CGImage);
        CGContextRestoreGState(outputContext);
    }
    
    // Add in color tint.
    if (tintColor) {
        CGContextSaveGState(outputContext);
        CGContextSetFillColorWithColor(outputContext, tintColor.CGColor);
        CGContextFillRect(outputContext, imageRect);
        CGContextRestoreGState(outputContext);
    }
    
    // Output image is ready.
    UIImage *outputImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return outputImage;
}

@end





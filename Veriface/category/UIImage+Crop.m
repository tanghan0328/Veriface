//
//  UIImage+Crop.m
//  bixin-ios
//
//  Created by Zhicheng Wei on 13/12/2016.
//  Copyright © 2016 bitpocket.im All rights reserved.
//

#import "UIImage+Crop.h"

@implementation UIImage (Crop)

- (UIImage *)imageWithCropRect:(CGRect)cropRect
{
    double (^rad)(double) = ^(double deg) {
        return deg / 180.0 * M_PI;
    };
    
    CGAffineTransform transform;
    switch (self.imageOrientation) {
        case UIImageOrientationLeft:
            transform = CGAffineTransformTranslate(CGAffineTransformMakeRotation(rad(90)), 0, -self.size.height);
            break;
        case UIImageOrientationRight:
            transform = CGAffineTransformTranslate(CGAffineTransformMakeRotation(rad(-90)), -self.size.width, 0);
            break;
        case UIImageOrientationDown:
            transform = CGAffineTransformTranslate(CGAffineTransformMakeRotation(rad(-180)), -self.size.width, -self.size.height);
            break;
        default:
            transform = CGAffineTransformIdentity;
    };
    
    transform = CGAffineTransformScale(transform, self.scale, self.scale);
    
    CGImageRef imageRef = CGImageCreateWithImageInRect([self CGImage],
                                                       CGRectApplyAffineTransform(cropRect, transform));
    
    UIImage *image = [UIImage imageWithCGImage:imageRef
                                         scale:self.scale
                                   orientation:self.imageOrientation];
    
    CGImageRelease(imageRef);
    
    return image;
}

/**
 *  @brief  根据颜色生成纯色图片
 *
 *  @param color 颜色
 *
 *  @return 纯色图片
 */
+ (UIImage *)imageWithColor:(UIColor *)color {
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

/**
 *  从图片中按指定的位置大小截取图片的一部分
 *
 *  @param image UIImage image 原始的图片
 *  @param rect  CGRect rect 要截取的区域
 *
 *  @return UIImage
 */
+ (UIImage *)ct_imageFromImage:(UIImage *)image inRect:(CGRect)rect
{
    
    //把像 素rect 转化为 点rect（如无转化则按原图像素取部分图片）
    CGFloat scale = [UIScreen mainScreen].scale;
    CGFloat x= rect.origin.x*scale,y=rect.origin.y*scale,w=rect.size.width*scale,h=rect.size.height*scale;
    CGRect dianRect = CGRectMake(x, y, w, h);
    
    //截取部分图片并生成新图片
    CGImageRef sourceImageRef = [image CGImage];
    if(sourceImageRef){
        CGImageRef newImageRef = CGImageCreateWithImageInRect(sourceImageRef, dianRect);
        UIImage *newImage = [UIImage imageWithCGImage:newImageRef scale:[UIScreen mainScreen].scale orientation:UIImageOrientationUp];
        return newImage;
    }
    return nil;
}
//从一个view钟截取图片大小
+ (UIImage*)imageFromView:(UIView*)view
{
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, YES, view.layer.contentsScale);
    
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return image;
}

// 压缩图片尺寸
//maxSize单位kb
- (UIImage *)scaleImageSize:(UIImage *)image maxSize:(CGFloat)maxSize
{
    CGFloat ratio = (CGFloat)maxSize / [self getImageLengthWithImage:image];
    if (maxSize < [self getImageLengthWithImage:image]) {
        image = [image imageByScalingToSize:CGSizeMake(image.size.width *sqrtf(ratio), image.size.height *sqrtf(ratio))];
        return [self scaleImageSize:image maxSize:maxSize];
    }
    return image;
}

- (CGFloat)getImageLengthWithImage:(UIImage *)image {
    NSData * imageData = UIImageJPEGRepresentation(image,1);
    CGFloat length = [imageData length]/1000;
    return length;
}

// 压缩图片
- (UIImage *)scaleImageCompression:(UIImage *)image {
    CGFloat origanSize = [self getImageLengthWithImage:image];
    
    NSData *imageData = UIImageJPEGRepresentation(image, 1);
    if (origanSize > 1024) {
        imageData=UIImageJPEGRepresentation(image, 0.1);
    } else if (origanSize > 512) {
        imageData=UIImageJPEGRepresentation(image, 0.5);
    }
    UIImage *image1 = [UIImage imageWithData:imageData];
    return image1;
}

//调整图片大小
- (UIImage *)imageByScalingToSize:(CGSize)targetSize
{
    
    UIImage *sourceImage = self;
    UIImage *newImage = nil;
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    CGFloat targetWidth = targetSize.width;
    CGFloat targetHeight = targetSize.height;
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    CGPoint thumbnailPoint = CGPointMake(0.0,0.0);
    if (CGSizeEqualToSize(imageSize, targetSize) == NO) {
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        if (widthFactor < heightFactor){
            scaleFactor = widthFactor;
        }else{
            scaleFactor = heightFactor;
        }
        scaledWidth  = width * scaleFactor;
        scaledHeight = height * scaleFactor;
        // center the image
        if (widthFactor < heightFactor) {
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
            
        } else if (widthFactor > heightFactor) {
            thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
        }
    }
    // this is actually the interesting part:
    UIGraphicsBeginImageContext(targetSize);
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width  = scaledWidth;
    thumbnailRect.size.height = scaledHeight;
    [sourceImage drawInRect:thumbnailRect];
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    if(newImage == nil)
        NSLog(@"could not scale image");
    return newImage ;
}

- (void)roundImageWithImageView:(UIImageView *)imageView size:(CGSize )size {
    UIGraphicsBeginImageContextWithOptions(size, NO, 3.0);
    [[UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, size.width, size.height)
                                cornerRadius:size.height] addClip];
    CGRect rect = CGRectZero;
    CGFloat scale = MAX(size.width / self.size.width, size.height / self.size.height);
    
    rect.size.width = self.size.width * scale;
    rect.size.height = self.size.height * scale;
    rect.origin.x = (size.width - rect.size.width) / 2.0;
    rect.origin.y = (size.height - rect.size.height) / 2.0;
    [self drawInRect:rect];
    imageView.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
}

+ (void)roundImageWithUrl:(NSString *)url
              atImageView:(UIImageView *)imageView
                     size:(CGSize)size {
    [imageView sd_setImageWithURL:[NSURL URLWithString:url] placeholderImage:[UIImage new] completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
        [image  roundImageWithImageView:imageView size:size];
    }];
}

@end

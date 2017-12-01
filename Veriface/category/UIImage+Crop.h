//
//  VFBaseViewController.h
//  Veriface
//
//  Created by tang tang on 2017/11/24.
//  Copyright © 2017年 tang tang. All rights reserved.
//


#import <UIKit/UIKit.h>

@interface UIImage (Crop)

- (UIImage *)imageWithCropRect:(CGRect)cropRect;

+ (UIImage *)imageWithColor:(UIColor *)color;

+ (UIImage *)ct_imageFromImage:(UIImage *)image inRect:(CGRect)rect;

+ (UIImage*)imageFromView:(UIView*)view;
//设置图片大小
- (UIImage *)imageByScalingToSize:(CGSize)targetSize;
// 压缩图片尺寸
- (UIImage *)scaleImageSize:(UIImage *)image maxSize:(CGFloat)maxSiz;

- (void)roundImageWithImageView:(UIImageView *)imageView size:(CGSize )size;

+ (void)roundImageWithUrl:(NSString *)url
              atImageView:(UIImageView *)imageView
                     size:(CGSize)size;
@end

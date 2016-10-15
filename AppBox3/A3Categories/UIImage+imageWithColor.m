//
//  UIImage+extension.m
//  AppBox3
//
//  Created by A3 on 11/27/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import "UIImage+imageWithColor.h"

@implementation UIImage (imageWithColor)

+ (UIImage *)imageWithColor:(UIColor *)color
{
    return [UIImage imageWithColor:color size:CGSizeMake(1, 1)];
}

+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size
{
    CGRect rect = CGRectMake(0.0f, 0.0f, size.width, size.height);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
	
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
	
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
	
    return image;
}

- (UIImage *)tintedImageWithColor:(UIColor *)tintColor
{
	// It's important to pass in 0.0f to this function to draw the image to the scale of the screen
	UIGraphicsBeginImageContextWithOptions(self.size, NO, 0.0f);
	[tintColor setFill];
	CGRect bounds = CGRectMake(0, 0, self.size.width, self.size.height);
	UIRectFill(bounds);
	[self drawInRect:bounds blendMode:kCGBlendModeDestinationIn alpha:1.0];

	UIImage *tintedImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();

	return tintedImage;
}

- (UIImage *)portraitImage {
	UIImage *imageCopy=nil;
	UIImageOrientation translatedOrientation = self.imageOrientation;
	switch (self.imageOrientation) {
		case UIImageOrientationUp:
			translatedOrientation = UIImageOrientationDownMirrored;
			break;
		case UIImageOrientationDown:
			translatedOrientation = UIImageOrientationUpMirrored;
			break;
		case UIImageOrientationLeft:
			translatedOrientation = UIImageOrientationLeftMirrored;
			break;
		case UIImageOrientationRight:
			translatedOrientation = UIImageOrientationRightMirrored;
			break;
		case UIImageOrientationUpMirrored:
			translatedOrientation = UIImageOrientationUp;
			break;
		case UIImageOrientationDownMirrored:
			translatedOrientation = UIImageOrientationDown;
			break;
		case UIImageOrientationLeftMirrored:
			translatedOrientation = UIImageOrientationLeft;
			break;
		case UIImageOrientationRightMirrored:
			translatedOrientation = UIImageOrientationRight;
			break;
	}

	CGImageRef imgRef = self.CGImage;

	CGFloat width = CGImageGetWidth(imgRef);
	CGFloat height = CGImageGetHeight(imgRef);

	CGAffineTransform transform;
	CGRect bounds = CGRectMake(0, 0, width, height);
	CGSize imageSize = CGSizeMake(CGImageGetWidth(imgRef), CGImageGetHeight(imgRef));
	CGFloat boundHeight;
	switch (translatedOrientation) {
		case UIImageOrientationUp: //EXIF = 1
			transform = CGAffineTransformIdentity;
			break;

		case UIImageOrientationUpMirrored: //EXIF = 2
			transform = CGAffineTransformMakeTranslation(imageSize.width, 0.0);
			transform = CGAffineTransformScale(transform, -1.0, 1.0);
			break;

		case UIImageOrientationDown: //EXIF = 3
			transform = CGAffineTransformMakeTranslation(imageSize.width, imageSize.height);
			transform = CGAffineTransformRotate(transform, M_PI);
			break;

		case UIImageOrientationDownMirrored: //EXIF = 4
			transform = CGAffineTransformMakeTranslation(0.0, imageSize.height);
			transform = CGAffineTransformScale(transform, 1.0, -1.0);
			break;

		case UIImageOrientationLeftMirrored: //EXIF = 5
			boundHeight = bounds.size.height;
			bounds.size.height = bounds.size.width;
			bounds.size.width = boundHeight;
			transform = CGAffineTransformMakeTranslation(imageSize.height, imageSize.width);
			transform = CGAffineTransformScale(transform, -1.0, 1.0);
			transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
			break;

		case UIImageOrientationLeft: //EXIF = 6
			boundHeight = bounds.size.height;
			bounds.size.height = bounds.size.width;
			bounds.size.width = boundHeight;
			transform = CGAffineTransformMakeTranslation(0.0, imageSize.width);
			transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
			break;

		case UIImageOrientationRightMirrored: //EXIF = 7
			boundHeight = bounds.size.height;
			bounds.size.height = bounds.size.width;
			bounds.size.width = boundHeight;
			transform = CGAffineTransformMakeScale(-1.0, 1.0);
			transform = CGAffineTransformRotate(transform, M_PI / 2.0);
			break;

		case UIImageOrientationRight: //EXIF = 8
			boundHeight = bounds.size.height;
			bounds.size.height = bounds.size.width;
			bounds.size.width = boundHeight;
			transform = CGAffineTransformMakeTranslation(imageSize.height, 0.0);
			transform = CGAffineTransformRotate(transform, M_PI / 2.0);
			break;

		default:
			[NSException raise:NSInternalInconsistencyException format:@"Invalid image orientation"];

	}

	UIGraphicsBeginImageContext(bounds.size);

	CGContextRef context = UIGraphicsGetCurrentContext();

	CGContextConcatCTM(context, transform);

	CGContextDrawImage(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, width, height), imgRef);
	imageCopy = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();

	return imageCopy;
}

+ (UIImage *)toolbarBackgroundImage
{
	UIGraphicsBeginImageContext(CGSizeMake(1,1));
	CGContextRef context = UIGraphicsGetCurrentContext();
	[[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.3] setFill];
	CGContextFillRect(context, CGRectMake(0, 0, 1, 1));
	UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	return [image resizableImageWithCapInsets:UIEdgeInsetsZero resizingMode:UIImageResizingModeStretch];
}

@end

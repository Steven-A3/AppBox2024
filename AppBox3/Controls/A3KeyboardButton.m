//
//  A3KeyboardButton.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 12/21/12.
//  Copyright (c) 2012 ALLABOUTAPPS. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "A3KeyboardButton.h"
#import "A3UIKit.h"
#import "common.h"

@interface A3KeyboardButton ()

@property (nonatomic, strong)	CAGradientLayer *gradientLayer;
@property (nonatomic, strong)	UILabel *titleLabel;
@property (nonatomic, strong)	NSString *text;
@property (nonatomic, strong)	UIImage *image;

@end

@implementation A3KeyboardButton
@synthesize titleLabel = _titleLabel;

- (id)initWithCoder:(NSCoder *)aDecoder {
	self = [super initWithCoder:aDecoder];
	if (self) {
		[self setupLayer];
	}

	return self;
}

- (void)setFrame:(CGRect)frame {
	[super setFrame:frame];

	[self setupLayer];
}

- (void)setupLayer {
	self.layer.shadowOffset=CGSizeMake(0, 1);
	self.layer.shadowRadius=1;
	self.layer.shadowOpacity=0.7;
	self.layer.shadowColor=[UIColor blackColor].CGColor;
	self.layer.shadowPath=[self newPathForRoundedRect:self.bounds radius:7];
}

-(void)setHighlighted:(BOOL)highlighted{
	[super setHighlighted:highlighted];
	[self setNeedsDisplay];
}

-(void)setSelected:(BOOL)selected{
	[super setSelected:selected];
	[self setNeedsDisplay];
}

-(void)setEnabled:(BOOL)enabled{
	[super setEnabled:enabled];
	[self setNeedsDisplay];
}

-(BOOL)isOpaque{
	return NO;
}

-(UIColor *)backgroundColor{
	return [UIColor clearColor];
}

- (void)drawRect:(CGRect)rect {
	CGContextRef context=UIGraphicsGetCurrentContext();

	CGContextSaveGState(context);

	CGPathRef keyBorderPath=[self newPathForRoundedRect:CGRectInset(rect, 0.5, 0.5) radius:7];


	//gradient
	CGContextSaveGState(context);
	//UIColor *ucolor1=[UIColor colorWithRed:239.0/255.0 green:239.0/255.0 blue:241.0/255 alpha:1];
	UIColor *ucolor1=[UIColor colorWithRed:241.0/255.0 green:241.0/255.0 blue:243.0/255 alpha:1];
	//UIColor *ucolor2=[UIColor colorWithRed:211.0/255.0 green:211.0/255.0 blue:217.0/255 alpha:1];
	UIColor *ucolor2=[UIColor colorWithRed:223.0/255.0 green:223.0/255.0 blue:231.0/255 alpha:1];

	if (self.state & (UIControlStateHighlighted | UIControlStateSelected)) {
		ucolor1=[UIColor colorWithRed:179.0/255.0 green:179.0/255.0 blue:187.0/255 alpha:1];
		ucolor2=[UIColor colorWithRed:130.0/255.0 green:130.0/255.0 blue:140.0/255 alpha:1];
	}

	CGColorRef color1=ucolor1.CGColor;
	CGColorRef color2=ucolor2.CGColor;

	CGGradientRef gradient;
	CGFloat locations[2] = { 0.0, 1.0 };
	NSArray *colors = [NSArray arrayWithObjects:(__bridge id)color1, (__bridge id)color2, nil];

	gradient = CGGradientCreateWithColors(NULL, (__bridge CFArrayRef)colors, locations);

	CGRect currentBounds = self.bounds;
	CGPoint topCenter = CGPointMake(CGRectGetMidX(currentBounds), 0.0f);
	CGPoint midCenter = CGPointMake(CGRectGetMidX(currentBounds), CGRectGetMaxY(currentBounds));

	CGContextAddPath(context, keyBorderPath);
	CGContextClip(context);
	CGContextDrawLinearGradient(context, gradient, topCenter, midCenter, 0);
	CGGradientRelease(gradient);
	CGContextRestoreGState(context);

	//overall gradient

	CGContextSaveGState(context);
	ucolor1=[UIColor colorWithRed:0.1 green:0.1 blue:0.11 alpha:0];
	ucolor2=[UIColor colorWithRed:0.1 green:0.1 blue:0.11 alpha:0.4];

	color1=ucolor1.CGColor;
	color2=ucolor2.CGColor;

	colors = [NSArray arrayWithObjects:(__bridge id)color1, (__bridge id)color2, nil];

	gradient = CGGradientCreateWithColors(NULL, (__bridge CFArrayRef)colors, locations);

	topCenter = CGPointMake(CGRectGetMidX(currentBounds), -(self.frame.origin.y));
	midCenter = CGPointMake(CGRectGetMidX(currentBounds), self.superview.bounds.size.height-(self.frame.origin.y));

	CGContextAddPath(context, keyBorderPath);
	CGContextClip(context);
	CGContextDrawLinearGradient(context, gradient, topCenter, midCenter, 0);
	CGGradientRelease(gradient);
	CGContextRestoreGState(context);

	//bottom inner shadow
	CGContextSaveGState(context);

	CGContextAddPath(context, keyBorderPath);
	CGContextEOClip(context);
	CGContextSetShadowWithColor(context, CGSizeMake(0, -1), 1, [UIColor colorWithWhite:0 alpha:0.5].CGColor);
	CGContextAddRect(context, CGRectInset(rect, -5, -5));
	CGContextAddPath(context, keyBorderPath);
	CGContextEOFillPath(context);

	CGContextRestoreGState(context);

	//top inner shadow
	CGContextSaveGState(context);

	CGContextAddPath(context, keyBorderPath);
	CGContextEOClip(context);
	CGContextSetShadowWithColor(context, CGSizeMake(0, 1), 0, [UIColor colorWithWhite:1 alpha:1].CGColor);
	CGContextAddRect(context, CGRectInset(rect, -5, -5));
	CGContextAddPath(context, keyBorderPath);
	CGContextEOFillPath(context);

	CGContextRestoreGState(context);

	//border
	CGContextSetLineWidth(context, 1);
	[[UIColor colorWithWhite:0.0 alpha:0.4] setStroke];
	CGContextAddPath(context, keyBorderPath);
	CGContextStrokePath(context);


	CGPathRelease(keyBorderPath);

	CGContextSetShadowWithColor(context, CGSizeMake(0, 1), 1, [UIColor colorWithWhite:1 alpha:1].CGColor);
	CGContextTranslateCTM(context, 0, rect.size.height);
	CGContextScaleCTM(context, 1.0, -1.0);

//	_image = [super imageForState:self.state];
//	FNLOG(@"%@", _image);
//	if (_text) {
//		//draw text
//		CGContextSetTextMatrix(context, CGAffineTransformIdentity);
//
//		//    create font
//		CGFontRef font = CTFontCreateWithName(CFSTR("Helvetica"), 26, NULL);
//
//
//		CGMutablePathRef path = CGPathCreateMutable();
//		CGRect boundingBox = CTFontGetBoundingBox(font);
//
//		//Get the position on the y axis
//		float midHeight = rect.size.height / 2;
//		midHeight -= boundingBox.size.height / 2;
//
//		CGPathAddRect(path, NULL, CGRectMake(0, midHeight, rect.size.width, boundingBox.size.height));
//		//CGPathAddRect(path, NULL, rect);
//
//		// Initialize an attributed string.
//		CFStringRef string = (__bridge_retained CFStringRef)self.text;//CFSTR("A");
//		CFMutableAttributedStringRef attrString = CFAttributedStringCreateMutable(kCFAllocatorDefault, 0);
//		CFAttributedStringReplaceString (attrString, CFRangeMake(0, 0), string);
//
//		//    create paragraph style and assign text alignment to it
//		CTTextAlignment alignment = kCTCenterTextAlignment;
//		CTParagraphStyleSetting _settings[] = {    {kCTParagraphStyleSpecifierAlignment, sizeof(alignment), &alignment} };
//		CTParagraphStyleRef paragraphStyle = CTParagraphStyleCreate(_settings, sizeof(_settings) / sizeof(_settings[0]));
//
//		//    set paragraph style attribute
//		CFAttributedStringSetAttribute(attrString, CFRangeMake(0, CFAttributedStringGetLength(attrString)), kCTParagraphStyleAttributeName, paragraphStyle);
//
//		//    set font attribute
//		CFAttributedStringSetAttribute(attrString, CFRangeMake(0, CFAttributedStringGetLength(attrString)), kCTFontAttributeName, font);
//		if (self.state & UIControlStateDisabled) {
//			CFAttributedStringSetAttribute(attrString, CFRangeMake(0, CFAttributedStringGetLength(attrString)), kCTForegroundColorAttributeName, [UIColor colorWithWhite:0.5 alpha:1].CGColor);
//		}
//
//		//    release paragraph style and font
//		CFRelease(paragraphStyle);
//		CFRelease(font);
//
//		// Create the framesetter with the attributed string.
//		CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString(attrString);
//		CFRelease(attrString);
//
//		// Create the frame and draw it into the graphics context
//		CTFrameRef frame = CTFramesetterCreateFrame(framesetter,
//				CFRangeMake(0, 0), path, NULL);
//		CFRelease(framesetter);
//		CTFrameDraw(frame, context);
//		CFRelease(frame);
//	}else if(_image){
//		// use image as mask to draw the key symbol
//
//		CGContextSaveGState(context);
//
//		CGImageRef maskRef = _image.CGImage;
//
//		CGImageRef mask = CGImageMaskCreate(CGImageGetWidth(maskRef),
//				CGImageGetHeight(maskRef),
//				CGImageGetBitsPerComponent(maskRef),
//				CGImageGetBitsPerPixel(maskRef),
//				CGImageGetBytesPerRow(maskRef),
//				CGImageGetDataProvider(maskRef), NULL, false);
//
//		CGRect maskRect=CGRectMake(0, 0, _image.size.width, _image.size.height);
//		maskRect=CGRectOffset(maskRect, (rect.size.width-maskRect.size.width)/2.0, (rect.size.height-maskRect.size.height)/2.0);
//		maskRect=CGRectIntegral(maskRect);
//		CGRect shadowMaskRect=CGRectOffset(maskRect, 0, -0.5);
//
//		CGContextClipToMask(context, shadowMaskRect, mask);
//
//		[[UIColor colorWithWhite:1 alpha:0.8] setFill];
//
//		CGContextFillRect(context, maskRect);
//
//		CGContextRestoreGState(context);
//
//		CGContextClipToMask(context, maskRect, mask);
//
//		if (self.state & UIControlStateDisabled) {
//			[[UIColor colorWithWhite:0.5 alpha:1] setFill];
//		}else{
//			[[UIColor blackColor] setFill];
//		}
//
//		CGContextFillRect(context, maskRect);
//
//		CGImageRelease(mask);
//	}

	CGContextRestoreGState(context);
}

- (CGMutablePathRef) newPathForRoundedRect:(CGRect) rect radius:(CGFloat)radius{
	CGMutablePathRef retPath = CGPathCreateMutable();

	CGRect innerRect = CGRectInset(rect, radius, radius);

	CGFloat inside_right = innerRect.origin.x + innerRect.size.width;
	CGFloat outside_right = rect.origin.x + rect.size.width;
	CGFloat inside_bottom = innerRect.origin.y + innerRect.size.height;
	CGFloat outside_bottom = rect.origin.y + rect.size.height;

	CGFloat inside_top = innerRect.origin.y;
	CGFloat outside_top = rect.origin.y;
	CGFloat outside_left = rect.origin.x;

	CGPathMoveToPoint(retPath, NULL, innerRect.origin.x, outside_top);

	CGPathAddLineToPoint(retPath, NULL, inside_right, outside_top);
	CGPathAddArcToPoint(retPath, NULL, outside_right, outside_top, outside_right, inside_top, radius);
	CGPathAddLineToPoint(retPath, NULL, outside_right, inside_bottom);
	CGPathAddArcToPoint(retPath, NULL,  outside_right, outside_bottom, inside_right, outside_bottom, radius);

	CGPathAddLineToPoint(retPath, NULL, innerRect.origin.x, outside_bottom);
	CGPathAddArcToPoint(retPath, NULL,  outside_left, outside_bottom, outside_left, inside_bottom, radius);
	CGPathAddLineToPoint(retPath, NULL, outside_left, inside_top);
	CGPathAddArcToPoint(retPath, NULL,  outside_left, outside_top, innerRect.origin.x, outside_top, radius);

	CGPathCloseSubpath(retPath);

	return retPath;
}

-(void)processKeyStroke:(id)sender{
	[[UIDevice currentDevice] playInputClick];
}

#pragma mark UIInputViewAudioFeedback

- (BOOL)enableInputClicksWhenVisible {
	return YES;
}

@end

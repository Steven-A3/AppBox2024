//
//  A3HexagonCell.m
//  HexagonMenu
//
//  Created by Byeong Kwon Kwak on 2/11/16.
//  Copyright © 2016 ALLABOUTAPPS. All rights reserved.
//

#import "A3HexagonCell.h"

@interface A3HexagonCell ()

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *noneLabel;

@end

@implementation A3HexagonCell

- (instancetype)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame])) {
        [self configureLayerForHexagon];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    if ((self = [super initWithCoder:coder])) {
        [self configureLayerForHexagon];
    }
    return self;
}

- (UIBezierPath *)borderPath {
	CGFloat width = self.frame.size.width;
	CGFloat height = self.frame.size.height;
//	CGFloat hPadding = width * 1 / 8 / 2;
	CGFloat hPadding = 0;

	//    UIGraphicsBeginImageContext(self.frame.size);
	UIBezierPath *path = [UIBezierPath bezierPath];
	[path moveToPoint:CGPointMake(width/2, 0)];
	[path addLineToPoint:CGPointMake(width - hPadding, height / 4)];
	[path addLineToPoint:CGPointMake(width - hPadding, height * 3 / 4)];
	[path addLineToPoint:CGPointMake(width / 2, height)];
	[path addLineToPoint:CGPointMake(hPadding, height * 3 / 4)];
	[path addLineToPoint:CGPointMake(hPadding, height / 4)];
	[path closePath];

	return path;
}

- (void)configureLayerForHexagon
{
	_enabled = YES;
	
    CGFloat red, green, blue, alpha;
	[self.borderColor getRed:&red green:&green blue:&blue alpha:&alpha];
	[UIColor colorWithRed:red green:green blue:blue alpha:0.6];
    
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.fillRule = kCAFillRuleEvenOdd;
    maskLayer.frame = self.bounds;
    
//    [path fill];
    maskLayer.path = self.borderPath.CGPath;
    //    UIGraphicsEndImageContext();
    self.layer.mask = maskLayer;
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];

    UIBezierPath *borderPath = [self borderPath];
	CGRect screenBounds = [A3UIDevice screenBoundsAdjustedWithOrientation];
	if (IS_IPAD_PRO) {
		borderPath.lineWidth = 13;
	} else {
		borderPath.lineWidth = IS_IPHONE ? (screenBounds.size.height <= 568 ? 5 : 6) : 10;
	}
	
	[self.borderColor setStroke];
    [borderPath stroke];
}

- (UIImageView *)imageView {
	if (!_imageView) {
		_imageView = [UIImageView new];
		_imageView.translatesAutoresizingMaskIntoConstraints = NO;
		[self addSubview:_imageView];

		[_imageView makeConstraints:^(MASConstraintMaker *make) {
			make.centerX.equalTo(self.centerX);
			make.centerY.equalTo(self.centerY);
			if (IS_IPAD_PRO) {
				make.width.equalTo(@80);
				make.height.equalTo(@80);
			} else if (IS_IPAD) {
				make.width.equalTo(@58);
				make.height.equalTo(@58);
			}
		}];
	}
	return _imageView;
}

- (void)setImageName:(NSString *)imageName {
	if (imageName == nil) {
		[_imageView removeFromSuperview];
		_imageView = nil;

		if (_enabled) {
			[self addSubview:self.noneLabel];
			
			[_noneLabel makeConstraints:^(MASConstraintMaker *make) {
				make.centerX.equalTo(self.centerX);
				make.centerY.equalTo(self.centerY).with.offset(-12);
			}];
			
			_noneLabel.textColor = _borderColor;
		} else {
			[self.noneLabel removeFromSuperview];
			_noneLabel = nil;
		}

		self.backgroundColor = [UIColor clearColor];
		return;
	}
	[_noneLabel removeFromSuperview];
	_noneLabel = nil;
	
	_imageName = [imageName copy];

	self.imageView.image = [[UIImage imageNamed:_imageName] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
	self.imageView.tintColor = [UIColor colorWithWhite:1.0 alpha:0.8];
}

- (void)setBorderColor:(UIColor *)borderColor {
	_borderColor = [borderColor copy];

	CGFloat red, green, blue, alpha;
	[self.borderColor getRed:&red green:&green blue:&blue alpha:&alpha];

	self.backgroundColor = [UIColor colorWithRed:red green:green blue:blue alpha:0.6];
}

- (UILabel *)noneLabel {
	if (!_noneLabel) {
		_noneLabel = [UILabel new];
		if (IS_IOS7) {
			_noneLabel.font = [UIFont fontWithName:@"TrebuchetMS" size:45];
		} else {
			_noneLabel.font = [UIFont boldSystemFontOfSize:45];
		}
		_noneLabel.text = @"…";
		_noneLabel.textAlignment = NSTextAlignmentCenter;
	}
	return _noneLabel;
}

@end

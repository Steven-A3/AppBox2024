//
//  A3GridMenuCollectionViewCell.m
//  HexagonMenu
//
//  Created by Byeong Kwon Kwak on 2/20/16.
//  Copyright © 2016 ALLABOUTAPPS. All rights reserved.
//

#import "A3GridMenuCollectionViewCell.h"
#import "A3GradientView.h"
#import "A3UserDefaults.h"
#import "A3AppDelegate.h"
#import "A3UIDevice.h"

@interface A3GridMenuCollectionViewCell ()

@property (nonatomic, strong) A3GradientView *roundedRectView;
@property (nonatomic, strong) UIImageView *imageView;

@end

@implementation A3GridMenuCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
	if ((self = [super initWithFrame:frame])) {
		[self setupSubviews];
	}
	return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
	if ((self = [super initWithCoder:coder])) {
		[self setupSubviews];
	}
	return self;
}

- (void)setupSubviews {
    if ([[A3UserDefaults standardUserDefaults] boolForKey:kA3AppsUseGrayIconsOnGridMenu]) {
        if (!_roundedRectView) {
            CGRect screenBounds = [A3UIDevice screenBoundsAdjustedWithOrientation];
            _roundedRectView = (id)[UIView new];
            _roundedRectView.backgroundColor = [UIColor clearColor];
            _roundedRectView.layer.borderColor = [UIColor clearColor].CGColor;
            if (IS_IPAD_PRO) {
                _roundedRectView.layer.cornerRadius = 22;
                _roundedRectView.layer.borderWidth = 4;
            } else {
                _roundedRectView.layer.cornerRadius = screenBounds.size.height == 480 ? 10.0 : 15.0;
                _roundedRectView.layer.borderWidth = screenBounds.size.height == 480 ? 2.3 : 3.0;
            }
            [self addSubview:_roundedRectView];
            
            [_roundedRectView makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(self.left);
                make.top.equalTo(self.top).with.offset(5);
                make.right.equalTo(self.right);
                make.height.equalTo(self.width);
            }];
            
            _imageView = [UIImageView new];
            [_roundedRectView addSubview:_imageView];
            
            [_imageView makeConstraints:^(MASConstraintMaker *make) {
                make.centerX.equalTo(_roundedRectView.centerX);
                make.centerY.equalTo(_roundedRectView.centerY);
                if (IS_IPAD && IS_IOS7) {
                    make.width.equalTo(@40);
                    make.height.equalTo(@40);
                }
                if (IS_IPAD_PRO) {
                    make.width.equalTo(@58);
                    make.height.equalTo(@58);
                }
            }];
            _imageView.layer.shadowColor = [UIColor blackColor].CGColor;
            _imageView.layer.shadowOffset = CGSizeMake(0, 2);
            _imageView.layer.shadowOpacity = 0.5;
            _imageView.layer.shadowRadius = 1.0;
            _imageView.clipsToBounds = NO;
            
            _titleLabel = [UILabel new];
            _titleLabel.textColor = [UIColor whiteColor];
            
            CGFloat fontSize;
            if (IS_IPAD_PRO) {
                fontSize = 18;
            } else if (screenBounds.size.height > 568) {
                fontSize = 13;
            } else {
                fontSize = 11;
            }
            _titleLabel.font = [UIFont systemFontOfSize:fontSize];
            _titleLabel.textAlignment = NSTextAlignmentCenter;
            _titleLabel.text = @"Unassigned";
            [self addSubview:_titleLabel];
            
            [_titleLabel makeConstraints:^(MASConstraintMaker *make) {
                make.centerX.equalTo(self.centerX);
                make.bottom.equalTo(self.bottom).with.offset(-5);
            }];
            
            _titleLabel.layer.shadowColor = [UIColor blackColor].CGColor;
            _titleLabel.layer.shadowOffset = CGSizeMake(0, 2);
            _titleLabel.layer.shadowOpacity = 0.5;
            _titleLabel.layer.shadowRadius = 1.0;
        }
    } else {
        if (!_roundedRectView) {
            CGRect screenBounds = [A3UIDevice screenBoundsAdjustedWithOrientation];
            _roundedRectView = [A3GradientView new];
            _roundedRectView.vertical = NO;
            _roundedRectView.layer.cornerRadius = self.bounds.size.width / 2;
            _roundedRectView.clipsToBounds = YES;
            [self addSubview:_roundedRectView];
            
            [_roundedRectView makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(self.left);
                make.top.equalTo(self.top);
                make.right.equalTo(self.right);
                make.height.equalTo(self.width);
            }];
            
            _imageView = [UIImageView new];
            [_roundedRectView addSubview:_imageView];
            
            [_imageView makeConstraints:^(MASConstraintMaker *make) {
                make.centerX.equalTo(_roundedRectView.centerX);
                make.centerY.equalTo(_roundedRectView.centerY);
                if (IS_IPAD && IS_IOS7) {
                    make.width.equalTo(@40);
                    make.height.equalTo(@40);
                }
                if (IS_IPAD_PRO) {
                    make.width.equalTo(@58);
                    make.height.equalTo(@58);
                }
            }];
            
            _titleLabel = [UILabel new];
            _titleLabel.textColor = [UIColor whiteColor];
            
            CGFloat fontSize;
            if (IS_IPAD_PRO) {
                fontSize = 18;
            } else if (screenBounds.size.height > 568) {
                fontSize = 13;
            } else {
                fontSize = 11;
            }
            _titleLabel.font = [UIFont systemFontOfSize:fontSize];
            _titleLabel.textAlignment = NSTextAlignmentCenter;
            _titleLabel.text = @"Unassigned";
            [self addSubview:_titleLabel];
            
            [_titleLabel makeConstraints:^(MASConstraintMaker *make) {
                make.centerX.equalTo(self.centerX);
                make.bottom.equalTo(self.bottom);
            }];
            
            _titleLabel.layer.shadowColor = [UIColor blackColor].CGColor;
            _titleLabel.layer.shadowOffset = CGSizeMake(0, 2);
            _titleLabel.layer.shadowOpacity = 0.5;
            _titleLabel.layer.shadowRadius = 1.0;
        }
    }
}

- (void)setBorderColor:(UIColor *)borderColor {
	_borderColor = [borderColor copy];

    if ([[A3UserDefaults standardUserDefaults] boolForKey:kA3AppsUseGrayIconsOnGridMenu]) {
        _roundedRectView.layer.borderColor = borderColor.CGColor;
        CGFloat red, green, blue, alpha;
        [borderColor getRed:&red green:&green blue:&blue alpha:&alpha];
        _roundedRectView.backgroundColor = [UIColor colorWithRed:red green:green blue:blue alpha:0.6];
    } else {
        CGFloat red, green, blue;
        [borderColor getRed:&red green:&green blue:&blue alpha:NULL];
        _roundedRectView.gradientColors = @[(id)borderColor.CGColor, (id)[UIColor colorWithRed:red green:green blue:blue alpha:0.6].CGColor];
        [_roundedRectView setNeedsDisplay];
    }
}

- (void)setImageName:(NSString *)imageName {
	_imageName = [imageName copy];

	_imageView.image = [[UIImage imageNamed:imageName] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
	_imageView.tintColor = [UIColor colorWithWhite:1.0 alpha:1.0];
}

@end

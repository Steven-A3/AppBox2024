//
//  A3TimeLineTableViewCell.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 12/6/12.
//  Copyright (c) 2012 ALLABOUTAPPS. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "A3TimeLineTableViewCell.h"
#import "A3TimeLineEventItemView.h"
#import "UIImage+Resizing.h"

@interface A3TimeLineTableViewCell ()
@property (nonatomic, strong) UIImageView *photoView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *subtitleLabel;
@property (nonatomic, strong) UILabel *datetimeLabel;
@property (nonatomic, strong) UILabel *locationLabel;
@property (nonatomic, strong) A3TimeLineEventItemView *borderView;

@end

// Image view size : 310 x 194
@implementation A3TimeLineTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
		self.frame = CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.bounds), 80.0f);

		CGFloat margin = 10.0f;
		CGFloat width = CGRectGetWidth(self.bounds);
		_borderView = [[A3TimeLineEventItemView alloc] initWithFrame:CGRectMake(margin, 5.0f, width - 20.0f, 65.0f)];
		_borderView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
		[self addSubview:_borderView];
	}
    return self;
}

- (UIImageView *)photoView {
	if (nil == _photoView) {
		_photoView = [[UIImageView alloc] initWithFrame:CGRectMake(5.0f, 5.0f, 310.0f, 194.0f)];
		[self addSubview:_photoView];
	}
	return _photoView;
}

- (void)setPhoto:(UIImage *)photo {
	if (nil == photo) {
		if (_photoView) {
			[_photoView removeFromSuperview];
			_photoView = nil;
			self.frame = CGRectMake(CGRectGetMinX(self.frame), CGRectGetMinY(self.frame), CGRectGetWidth(self.frame), 80.0f);
		}
		_photo = nil;
	} else{
		_photo = [photo cropToSize:CGSizeMake(310.0f, 194.0f) usingMode:NYXCropModeCenter];
		if (_photo) {
			self.frame = CGRectMake(CGRectGetMinX(self.bounds), CGRectGetMinY(self.bounds), CGRectGetWidth(self.bounds), 90.0f + 194.0f);
			self.photoView.image = _photo;
			[self.borderView setFrame:CGRectMake(10.0f, 5.0f + 194.0f, 300.0f, 65.0f)];
		}
	}
}

- (UILabel *)titleLabel {
	if (nil == _titleLabel) {
		_titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
		_titleLabel.backgroundColor = [UIColor clearColor];
		_titleLabel.font = [UIFont boldSystemFontOfSize:15.0f];
		_titleLabel.textColor = [UIColor blackColor];
		[self.borderView addSubview:_titleLabel];
	}
	return _titleLabel;
}

- (UILabel *)subtitleLabel {
	if (nil == _subtitleLabel) {
		_subtitleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
		_subtitleLabel.backgroundColor = [UIColor clearColor];
		_subtitleLabel.font = [UIFont systemFontOfSize:14.0f];
		_subtitleLabel.textColor = [UIColor lightGrayColor];
		[self.borderView addSubview:_subtitleLabel];
	}
	return _subtitleLabel;
}

- (UILabel *)datetimeLabel {
	if (nil == _datetimeLabel) {
		_datetimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0f, 47.0f, self.borderView.bounds.size.width - 20.0f, 14.0f)];
		_datetimeLabel.backgroundColor = [UIColor clearColor];
		_datetimeLabel.font = [UIFont systemFontOfSize:13.0f];
		_datetimeLabel.textColor = [UIColor lightGrayColor];
		[self.borderView addSubview:_datetimeLabel];
	}
	return _datetimeLabel;
}

- (UILabel *)locationLabel {
	if (nil == _locationLabel) {
		_locationLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0f, 47.0f, self.borderView.bounds.size.width - 20.0f, 14.0f)];
		_locationLabel.backgroundColor = [UIColor clearColor];
		_locationLabel.textAlignment = NSTextAlignmentRight;
		_locationLabel.font = [UIFont systemFontOfSize:13.0f];
		_locationLabel.textColor = [UIColor lightGrayColor];
		[self.borderView addSubview:_locationLabel];
	}
	return _locationLabel;
}

- (void)layoutTitleAndSubtitle {
	CGFloat width = self.borderView.bounds.size.width - 20.0f;
	if ([self.titleLabel.text length] && [self.subtitleLabel.text length]) {
		self.titleLabel.frame = CGRectMake(10.0f, 7.0f, width, 16.0f);
		self.subtitleLabel.frame = CGRectMake(10.0f, 24.0f, width, 16.0f);
	} else if ([self.titleLabel.text length]) {
		_titleLabel.frame = CGRectMake(10.0f, 14.0f, width, 16.0f);
		[_subtitleLabel removeFromSuperview];
		_subtitleLabel = nil;
	} else if ([self.subtitleLabel.text length]) {
		self.subtitleLabel.frame = CGRectMake(10.0f, 14.0f, width, 16.0f);
		[_titleLabel removeFromSuperview];
		_titleLabel = nil;
	} else {
		[_titleLabel removeFromSuperview];
		_titleLabel = nil;
		[_subtitleLabel removeFromSuperview];
		_subtitleLabel = nil;
	}
}

- (void)setTitle:(NSString *)title {
	self.titleLabel.text = title;
	[self layoutTitleAndSubtitle];
}

- (void)setSubtitle:(NSString *)subtitle {
	self.subtitleLabel.text = subtitle;
	[self layoutTitleAndSubtitle];
}

- (void)setDatetimeText:(NSString *)datetimeText {
	self.datetimeLabel.text = datetimeText;
}

- (void)setLocationText:(NSString *)locationText {
	self.locationLabel.text = locationText;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

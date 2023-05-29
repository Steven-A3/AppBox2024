//
//  A3WalletListPhotoCell.m
//  A3TeamWork
//
//  Created by kihyunkim on 2013. 11. 20..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import <AppBoxKit/AppBoxKit.h>
#import "A3WalletListPhotoCell.h"

@implementation A3WalletListPhotoCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
		CGRect screenBounds = [A3UIDevice screenBoundsAdjustedWithOrientation];
		self.frame = CGRectMake(0.0, 0.0, screenBounds.size.width, 48);
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
		[self.contentView addSubview:self.rightLabel];
        
        for (int i=0; i<self.thumbImgViews.count; i++) {
            UIImageView *thumbImgView = _thumbImgViews[i];
            [self.contentView addSubview:thumbImgView];
        }
        
        [self resetThumbImages];
		[self useDynamicType];
    }
    return self;
}

- (void)prepareForReuse {
	[super prepareForReuse];
    
	[self useDynamicType];
    [self resetThumbImages];
}

- (void)useDynamicType {
	self.rightLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [_rightLabel sizeToFit];
    _rightLabel.center = CGPointMake(self.contentView.bounds.size.width, self.contentView.center.y);
    
	CGFloat leading = IS_IPHONE ? ([[UIScreen mainScreen] scale] > 2 ? 20 : 15) : 28;
	CGFloat centerY = self.contentView.center.y;

    if (!IS_RETINA) {
		centerY = (CGFloat) floor(centerY);
	}
    for (NSInteger idx = 0; idx < _thumbImgViews.count; idx++) {
        UIImageView *thumbImgView = _thumbImgViews[idx];
        CGFloat width = thumbImgView.bounds.size.width;
        thumbImgView.center = CGPointMake(leading + idx * (width + 10) + width/2.0, centerY);
    }
	FNLOG(@"%f", self.contentView.center.y);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (UILabel *)rightLabel
{
    if (!_rightLabel) {
        _rightLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 30)];
        _rightLabel.layer.anchorPoint = CGPointMake(1, 0.5);
    }
    
    return _rightLabel;
}

- (NSMutableArray *)thumbImgViews
{
    if (!_thumbImgViews) {
        _thumbImgViews = [[NSMutableArray alloc] init];
        NSUInteger maxNum = (IS_IPAD) ? 5:2;
        
        for (int i=0; i<maxNum; i++) {
            UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 32, 32)];
//            imgView.layer.anchorPoint = CGPointMake(0, 0.5);
            imgView.layer.cornerRadius = 16;
            imgView.layer.masksToBounds = YES;
            [_thumbImgViews addObject:imgView];
        }
    }
    
    return _thumbImgViews;
}

- (CGSize)sizeThatFits:(CGSize)size {
	return [self intrinsicContentSize];
}

- (CGSize)intrinsicContentSize {
	CGRect screenBounds = [A3UIDevice screenBoundsAdjustedWithOrientation];
	if (IS_IPAD) {
		return CGSizeMake(714.0, 48.0);
	} else {
        return CGSizeMake(screenBounds.size.width, 48.0);
    }
}

- (void)resetThumbImages
{
    for (UIImageView *thumbImgView in _thumbImgViews) {
        thumbImgView.image = nil;
		for (UIView *markView in thumbImgView.subviews) {
			[markView removeFromSuperview];
		}
    }
}

- (void)addThumbImage:(UIImage *)thumb isVideo:(BOOL)isVideo {
    for (NSUInteger idx = 0; idx < _thumbImgViews.count; idx++) {
        UIImageView *thumbImgView = _thumbImgViews[idx];
        if (thumbImgView.image == nil) {
            thumbImgView.image = thumb;

			if (isVideo) {
				UIImageView *markView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"video"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
				markView.tintColor = [UIColor whiteColor];
				[thumbImgView addSubview:markView];
				[markView makeConstraints:^(MASConstraintMaker *make) {
					make.center.equalTo(thumbImgView);
					make.width.equalTo(@15);
					make.height.equalTo(@9);
				}];
			}
            break;
        }
    }
}

@end

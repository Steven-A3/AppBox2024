//
//  A3WalletListBigVideoCell.m
//  A3TeamWork
//
//  Created by kihyunkim on 2013. 11. 30..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import "A3WalletListBigVideoCell.h"
#import "A3UIDevice.h"
#import "common.h"

#define TimeLabelTag 1000

@implementation A3WalletListBigVideoCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
		CGRect screenBounds = [A3UIDevice screenBoundsAdjustedWithOrientation];
        self.frame = CGRectMake(0.0, 0.0, screenBounds.size.width, 84);
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
		[self.contentView addSubview:self.rightLabel];
        
        for (int i=0; i<self.thumbImgViews.count; i++) {
            UIImageView *thumbImgView = _thumbImgViews[i];
            [self.contentView addSubview:thumbImgView];
        }
        
		[self useDynamicType];
        [self resetThumbImages];
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
    
    for (int i=0; i<_thumbImgViews.count; i++) {
        UIImageView *thumbImgView = _thumbImgViews[i];
        
        thumbImgView.center = CGPointMake(i*(thumbImgView.bounds.size.width + 4), self.contentView.center.y);
    }
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
            UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 80, 80)];
            imgView.layer.anchorPoint = CGPointMake(0, 0.5);
            [_thumbImgViews addObject:imgView];
            
            UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, 60, 80, 20)];
            CAGradientLayer *gradient = [CAGradientLayer layer];
            gradient.frame = bottomView.bounds;
            UIColor *color1 = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
            UIColor *color2 = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
            gradient.colors = @[(id)color1.CGColor, (id)color2.CGColor];
            [bottomView.layer insertSublayer:gradient atIndex:0];
            [imgView addSubview:bottomView];
            
            UIImageView *markView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"video"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
			markView.tintColor = [UIColor whiteColor];
            markView.frame = CGRectMake(0, 0, 15, 9);
            [imgView addSubview:markView];
            markView.center = CGPointMake(12, 71);
            
            UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 50, 20)];
            timeLabel.tag = TimeLabelTag;
            timeLabel.font = [UIFont systemFontOfSize:13];
            timeLabel.textColor = [UIColor whiteColor];
            timeLabel.layer.anchorPoint = CGPointMake(1, 1);
            timeLabel.center = CGPointMake(75, 80);
            [imgView addSubview:timeLabel];
            [timeLabel setTextAlignment:NSTextAlignmentRight];
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
        thumbImgView.hidden = YES;
    }
}

- (void)addThumbImage:(UIImage *)thumb withDuration:(float)duration
{
    for (int i=0; i<_thumbImgViews.count; i++) {
        UIImageView *thumbImgView = _thumbImgViews[i];
        if (thumbImgView.image == nil) {
            thumbImgView.image = thumb;
            thumbImgView.hidden = NO;
            UILabel *timeLabel = (UILabel *)[thumbImgView viewWithTag:TimeLabelTag];
            NSInteger minutes = floor(duration/60);
            NSInteger seconds = round(duration - minutes * 60);
            timeLabel.text = [NSString stringWithFormat:@"%ld:%02ld", (long)minutes, (long)seconds];
            break;
        }
    }
}

@end

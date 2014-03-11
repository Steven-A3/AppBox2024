//
//  A3WalletListPhotoCell.m
//  A3TeamWork
//
//  Created by kihyunkim on 2013. 11. 20..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import "A3WalletListPhotoCell.h"
#import "A3UIDevice.h"
#import "common.h"

@implementation A3WalletListPhotoCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.frame = CGRectMake(0.0, 0.0, 320.0, 48);
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
    
    float leftMargin = (IS_IPHONE) ? 15:28;
    
    for (int i=0; i<_thumbImgViews.count; i++) {
        UIImageView *thumbImgView = _thumbImgViews[i];
        
        thumbImgView.center = CGPointMake(leftMargin+i*(thumbImgView.bounds.size.width + 10), self.contentView.center.y);
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
            UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 32, 32)];
            imgView.layer.anchorPoint = CGPointMake(0, 0.5);
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
	if (IS_IPAD) {
		return CGSizeMake(714.0, 48.0);
	} else {
        return CGSizeMake(320.0, 48.0);
    }
}

- (void)resetThumbImages
{
    for (UIImageView *thumbImgView in _thumbImgViews) {
        thumbImgView.image = nil;
    }
}

- (void)addThumbImage:(UIImage *)thumb
{
    for (int i=0; i<_thumbImgViews.count; i++) {
        UIImageView *thumbImgView = _thumbImgViews[i];
        if (thumbImgView.image == nil) {
            thumbImgView.image = thumb;
            break;
        }
    }
}

@end

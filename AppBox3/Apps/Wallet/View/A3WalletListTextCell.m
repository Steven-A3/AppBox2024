//
//  A3WalletListTextCell.m
//  A3TeamWork
//
//  Created by kihyunkim on 2013. 11. 19..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import "A3WalletListTextCell.h"
#import "A3UIDevice.h"

@implementation A3WalletListTextCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    // layout
    if (IS_IPAD) {

        CGPoint center = _titleLabel.center;
        center.y = self.contentView.bounds.size.height/2;
        _titleLabel.center = center;
        
        CGRect titleRect = _titleLabel.frame;
        titleRect.origin.x = 28;
        _titleLabel.frame = titleRect;
        
        _detailLabel.textAlignment = NSTextAlignmentRight;
        _detailLabel.layer.anchorPoint = CGPointMake(1, 0.5);
        _detailLabel.center = CGPointMake(self.contentView.bounds.size.width, _titleLabel.center.y);
    }
}

@end

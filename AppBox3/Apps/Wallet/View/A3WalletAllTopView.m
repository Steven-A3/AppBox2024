//
//  A3WalletAllTopView.m
//  A3TeamWork
//
//  Created by kihyunkim on 2013. 11. 14..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import "A3WalletAllTopView.h"

@interface A3WalletAllTopView ()

@end

@implementation A3WalletAllTopView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)addSubviewConstraints
{
    _sortingSegment.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_sortingSegment
														  attribute:NSLayoutAttributeCenterX
														  relatedBy:NSLayoutRelationEqual
															 toItem:self
														  attribute:NSLayoutAttributeCenterX
														 multiplier:1.0 constant:0.0]];
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [self addSubviewConstraints];
    
    [_sortingSegment setWidth:IS_IPAD ? 150:85 forSegmentAtIndex:0];
    [_sortingSegment setWidth:IS_IPAD ? 150:85 forSegmentAtIndex:1];
}

- (void)make1LinePixel
{
    if (IS_RETINA) {
        for (UIView *line in _horLines) {
            CGRect rect = line.frame;
            rect.size.height = 0.5f;
            if (line.tag == 1000) {
                rect.origin.y = 95.5;
            }
            line.frame = rect;
        }
        
        for (UIView *line in _vertLines) {
            CGRect rect = line.frame;
            rect.origin.y = 0.5;
            rect.size.width = 0.5;
            rect.size.height = 54.5;
            line.frame = rect;
        }
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self make1LinePixel];
}

@end

//
//  A3BatteryStatusListPageSectionView.m
//  A3TeamWork
//
//  Created by jeonghwan kim on 12/4/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import "A3BatteryStatusListPageSectionView.h"

@implementation A3BatteryStatusListPageSectionView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor colorWithRed:239.0/255.0 green:239.0/255.0 blue:244.0/255.0 alpha:1.0];
        [self initializeSubviews];
        [self setupConstraintLayout];
    }
    return self;
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    [self adjustConstraintLayout];
}

-(void)initializeSubviews
{
    _tableSegmentButton = [[UISegmentedControl alloc] initWithItems:@[NSLocalizedString(@"About", @"Battery Life Title Segmented Control title"), NSLocalizedString(@"Remaining Time", @"Remaining Time")]];
	_tableSegmentButton.backgroundColor = [UIColor whiteColor];
//    _tableSegmentButton.layer.cornerRadius = 5;
    CAShapeLayer* mask = [[CAShapeLayer alloc] init];
    mask.frame = CGRectMake(0, 0, IS_IPHONE ? 224 : 300, _tableSegmentButton.bounds.size.height);
    mask.path = [[UIBezierPath bezierPathWithRoundedRect:mask.frame cornerRadius:4] CGPath];
    _tableSegmentButton.layer.mask = mask;

    _leftTextLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _rightTextLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    [self addSubview:_tableSegmentButton];
    [self addSubview:_leftTextLabel];
    [self addSubview:_rightTextLabel];
}

-(void)setupConstraintLayout
{
    [_tableSegmentButton makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.centerX);
        make.centerY.equalTo(self.centerY);
		make.width.equalTo(IS_IPHONE ? @170 : @300);
    }];
    
    [_leftTextLabel makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.left).with.offset(10.0);
        make.bottom.equalTo(self.bottom).with.offset(-10.0);
    }];
    [_rightTextLabel makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(self.right).with.offset(-10.0);
        make.bottom.equalTo(self.bottom).with.offset(-10.0);
    }];
}

-(void)adjustConstraintLayout
{
    [_leftTextLabel sizeToFit];
    [_rightTextLabel sizeToFit];
}

@end

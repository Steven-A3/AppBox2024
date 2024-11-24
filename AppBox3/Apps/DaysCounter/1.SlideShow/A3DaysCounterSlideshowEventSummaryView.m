//
//  A3DaysCounterSlideshowEventSummaryView.m
//  AppBox3
//
//  Created by dotnetguy83 on 3/22/14.
//  Copyright (c) 2014 ALLABOUTAPPS. All rights reserved.
//

#import "A3DaysCounterSlideshowEventSummaryView.h"
#import "A3GradientView.h"

@implementation A3DaysCounterSlideshowEventSummaryView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void)awakeFromNib
{
    [super awakeFromNib];
    
    [self setupShadowGradientView];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (A3GradientView *)setupShadowGradientView {
    if (!_shadowGradientView) {
        _shadowGradientView = [A3GradientView new];
        _shadowGradientView.gradientColors = @[
                                               (id) [UIColor colorWithWhite:0.0 alpha:0.17].CGColor,
                                               (id) [UIColor colorWithWhite:0.0 alpha:0.0].CGColor,
                                               (id) [UIColor colorWithWhite:0.0 alpha:0.17].CGColor
                                               ];
        _shadowGradientView.locations = @[
                                          @(0.03),
                                          @(0.5),
                                          @(0.85)
                                          ];

        [_photoImageView addSubview:_shadowGradientView];
        [_shadowGradientView makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self->_photoImageView.left);
            make.right.equalTo(self->_photoImageView.right);
            make.top.equalTo(self->_photoImageView.top);
            make.bottom.equalTo(self->_photoImageView.bottom);
        }];
    }

    return _shadowGradientView;
}

@end

//
//  A3SBTickerView.m
//  A3TeamWork
//
//  Created by Sanghyun Yu on 2013. 11. 27..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import "A3SBTickerView.h"
#import "A3ClockFoldPaperView.h"
#import "A3ClockDataManager.h"


@implementation A3SBTickerView

- (void)setFrontView:(UIView *)frontView
{
    [super setFrontView:frontView];
    
    [frontView makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.centerX);
        make.centerY.equalTo(self.centerY);
        make.width.equalTo(self.width);
        make.height.equalTo(self.height);
    }];
}

@end

//
//  A3ClockFoldPaperView.m
//  A3TeamWork
//
//  Created by Sanghyun Yu on 2013. 11. 27..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import "A3ClockFoldPaperView.h"
#import "A3ClockDataManager.h"
#import "NSUserDefaults+A3Defaults.h"

@interface A3ClockFoldPaperView ()

@end

@implementation A3ClockFoldPaperView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.textLabel = [[UILabel alloc] initWithFrame:self.bounds];
        [self.textLabel setTextColor:[UIColor whiteColor]];
        [self.textLabel setTextAlignment:NSTextAlignmentCenter];
        
		[self addSubview:self.textLabel];

        [self.textLabel makeConstraints:^(MASConstraintMaker *make) {
			make.centerX.equalTo(self.centerX);
			make.centerY.equalTo(self.centerY);
		}];

        _viewCenter = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, 1)];
        [self addSubview:_viewCenter];

        [_viewCenter makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.centerX);
            make.centerY.equalTo(self.centerY);
            make.width.equalTo(self.width);
            make.height.equalTo(@2);
        }];

        self.layer.cornerRadius = 5;
        self.layer.masksToBounds = YES;
    }
    return self;
    
}

@end

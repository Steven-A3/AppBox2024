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

@property (nonatomic, strong) UIView* viewCenter;

@end

@implementation A3ClockFoldPaperView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.lbTime = [[UILabel alloc] initWithFrame:self.bounds];
        [self.lbTime setBackgroundColor:[UIColor clearColor]];
        [self.lbTime setTextColor:[UIColor blackColor]];
        [self.lbTime setTextAlignment:NSTextAlignmentCenter];
        
        if([[NSUserDefaults standardUserDefaults] clockTheTimeWithSeconds])
            [self.lbTime setFont:[UIFont fontWithName:kClockFontNameMedium size:64.f]];
        else
            [self.lbTime setFont:[UIFont fontWithName:kClockFontNameMedium size:112.f]];
        [self addSubview:self.lbTime];
        [self.lbTime makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.centerX);
            make.centerY.equalTo(self.centerY);
            make.width.equalTo(self.width);
            make.height.equalTo(self.height);
        }];
        
        
        _viewCenter = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, 2)];
        [_viewCenter setBackgroundColor:[UIColor whiteColor]];
        [self addSubview:_viewCenter];
        [_viewCenter setCenter:CGPointMake(self.frame.size.width*0.5, self.frame.size.height* 0.5)];
        [_viewCenter makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.centerX);
            make.centerY.equalTo(self.centerY);
            make.width.equalTo(self.width);
            make.height.equalTo(@2);
        }];
        
        
        self.layer.cornerRadius = 5;
        self.layer.masksToBounds = YES;
        
        [self setBackgroundColor:[UIColor blueColor]];
    }
    return self;
    
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    
    if([[NSUserDefaults standardUserDefaults] clockTheTimeWithSeconds]) {
		[self.lbTime setFont:[UIFont fontWithName:kClockFontNameMedium size:64]];
	} else {
		[self.lbTime setFont:[UIFont fontWithName:kClockFontNameMedium size:112]];
	}
}

@end

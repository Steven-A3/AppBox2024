//
//  A3ChooseColor.m
//  A3TeamWork
//
//  Created by Sanghyun Yu on 2013. 11. 29..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import "A3ChooseColor.h"
#import "A3ClockDataManager.h"
#import "A3ChooseColorPhone.h"
#import "A3ChooseColorPad.h"
#import "A3UIDevice.h"

@implementation A3ChooseColor

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


+ (A3ChooseColor *)chooseColorWaveInViewController:(UIViewController <A3ChooseColorDelegate> *)targetViewController colors:(NSArray *)colors selectedIndex:(NSUInteger)selectedIndex {
	CGRect screenBounds = [A3UIDevice screenBoundsAdjustedWithOrientation];
	CGRect frame = screenBounds;
	frame.origin.y = screenBounds.size.height;
	frame.size.height = 172;

	A3ChooseColorPhone *view = [[A3ChooseColorPhone alloc] initWithFrame:frame colors:colors selectedIndex:selectedIndex];
    view.delegate = targetViewController;

	[targetViewController.view addSubview:view];

	[UIView animateWithDuration:0.3 animations:^{
		CGRect frame = view.frame;
		frame.origin.y -= frame.size.height;
		view.frame = frame;
	} completion:^(BOOL finished) {
		[view makeConstraints:^(MASConstraintMaker *make) {
			make.bottom.equalTo(targetViewController.view.bottom);
			make.width.equalTo(targetViewController.view.width);
			make.height.equalTo(@172.f);
		}];
	}];

    return view;
}

+ (A3ChooseColor *)chooseColorFlipInViewController:(UIViewController <A3ChooseColorDelegate> *)targetViewController colors:(NSArray *)colors {
    A3ChooseColorPhone* choClr = [[A3ChooseColorPhone alloc] initWithFrame:CGRectMake(0, 0, 320.f, 172.f)];
    [targetViewController.view addSubview:choClr];
    [choClr makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(targetViewController.view.bottom).with.offset(0);
        make.left.equalTo(targetViewController.view.left).with.offset(0);
        make.right.equalTo(targetViewController.view.right).with.offset(0);
    }];
    
    return choClr;
}

+ (A3ChooseColor *)chooseColorLED:(UIViewController <A3ChooseColorDelegate> *)targetViewController colors:(NSArray *)colors {
    A3ChooseColorPhone* choClr = [[A3ChooseColorPhone alloc] initWithFrame:CGRectMake(0, 0, 320.f, 172.f)];
    [targetViewController.view addSubview:choClr];
    [choClr makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(targetViewController.view.bottom).with.offset(0);
		make.left.equalTo(targetViewController.view.left).with.offset(0);
        make.right.equalTo(targetViewController.view.right).with.offset(0);
    }];
    
    return choClr;
}


- (void)colorButtonAction:(UIButton *)colorButton
{
	id <A3ChooseColorDelegate> o = self.delegate;
	if ([o respondsToSelector:@selector(chooseColorDidSelect:selectedIndex:)]) {
		[o chooseColorDidSelect:colorButton.backgroundColor selectedIndex:(NSUInteger) colorButton.tag];
	}
}

- (void)closeButtonAction
{
	id <A3ChooseColorDelegate> o = self.delegate;
	if ([o respondsToSelector:@selector(chooseColorDidCancel)]) {
		[o chooseColorDidCancel];
	}
}

@end

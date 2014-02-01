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


+ (A3ChooseColor *)chooseColorWaveInViewController:(UIViewController <A3ChooseColorDelegate> *)targetViewController inView:(UIView *)view colors:(NSArray *)colors selectedIndex:(NSUInteger)selectedIndex {
	CGRect screenBounds = [A3UIDevice screenBoundsAdjustedWithOrientation];
	CGRect frame = screenBounds;
	frame.origin.y = screenBounds.size.height;
	frame.size.height = IS_IPHONE ? 172 : 280;

	A3ChooseColorPhone *chooseColorView = [[A3ChooseColorPhone alloc] initWithFrame:frame colors:colors selectedIndex:selectedIndex];
    chooseColorView.delegate = targetViewController;

	[view addSubview:chooseColorView];

	[UIView animateWithDuration:0.3 animations:^{
		CGRect frame = chooseColorView.frame;
		frame.origin.y -= frame.size.height;
		chooseColorView.frame = frame;
	} completion:^(BOOL finished) {
		[chooseColorView makeConstraints:^(MASConstraintMaker *make) {
			make.left.equalTo(view.left);
			make.right.equalTo(view.right);
			make.bottom.equalTo(view.bottom);
			make.height.equalTo(@(frame.size.height));
		}];
	}];

    return chooseColorView;
}

- (void)closeButtonAction
{
	id <A3ChooseColorDelegate> o = self.delegate;
	if ([o respondsToSelector:@selector(chooseColorDidCancel)]) {
		[o chooseColorDidCancel];
	}
}

@end

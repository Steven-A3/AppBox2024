//
//  A3DatePickerView
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 5/9/13 6:11 PM.
//  Copyright (c) 2012 ALLABOUTAPPS. All rights reserved.
//

#import "A3DatePickerView.h"
#import "CommonUIDefinitions.h"
#import "A3_30x30Button.h"

@interface A3DatePickerView ()

@property (nonatomic, strong, readonly) A3_30x30Button *todayButton;

@end

@implementation A3DatePickerView {

}
@synthesize datePicker = _datePicker;
@synthesize todayButton = _todayButton;

- (id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	if (self) {
		// Fixed width and height view
		// Top 40 points clear colored toolbar
		// 216 points height UIDatePicker

	}

	return self;
}

- (CGSize)sizeThatFits:(CGSize)size {
	return CGSizeMake(SIDE_VIEW_WIDTH, 40.0 + PICKER_VIEW_HEIGHT);
}

- (UIDatePicker *)datePicker {
	if (nil == _datePicker) {
		_datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0.0, 40.0, SIDE_VIEW_WIDTH, PICKER_VIEW_HEIGHT)];
	}
	return _datePicker;
}

- (A3_30x30Button *)todayButton {
	if (nil == _todayButton) {
		_todayButton = [[A3_30x30Button alloc] initWithFrame:CGRectMake(10.0, 0.0, 30.0, 30.0)];
		[_todayButton setTitle:@"T" forState:UIControlStateNormal];
		_todayButton.titleLabel.font = [UIFont boldSystemFontOfSize:24.0];
		[_todayButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
		[_todayButton addTarget:self action:@selector(todayButtonAction) forControlEvents:UIControlEventTouchUpInside];
	}
	return _todayButton;
}

- (void)todayButtonAction {
	self.datePicker.date = [NSDate date];
}

- (void)configure {
	self.backgroundColor = [UIColor clearColor];
	[self addSubview:self.datePicker];
	[self addSubview:self.todayButton];
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
	[super willMoveToSuperview:newSuperview];

	[self configure];
}

@end
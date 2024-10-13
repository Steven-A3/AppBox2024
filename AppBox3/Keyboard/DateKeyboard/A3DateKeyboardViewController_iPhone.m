//
//  A3DateKeyboardViewController_iPhone.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 5/22/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import "A3DateKeyboardViewController_iPhone.h"
#import "A3KeyboardButton_iPhone.h"
#import "A3KeyboardButton_iOS7_iPhone.h"

@interface A3DateKeyboardViewController_iPhone ()

@property (nonatomic, weak) IBOutlet NSLayoutConstraint *bottomSpaceConstraint;

@end

@implementation A3DateKeyboardViewController_iPhone

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIEdgeInsets safeAreaInsets = [[[UIApplication sharedApplication] myKeyWindow] safeAreaInsets];
    if (safeAreaInsets.top > 20) {
        _bottomSpaceConstraint.constant = safeAreaInsets.bottom;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)removeExtraLabelsForButton:(UIButton *)button {
	A3KeyboardButton_iPhone *aButton = (A3KeyboardButton_iPhone *) button;
	if ([aButton respondsToSelector:@selector(removeExtraLabels)]) {
		[aButton removeExtraLabels];
	}
}

- (void)initExtraLabels {
	[self removeExtraLabelsForButton:self.num7_Jan_Button];
	[self removeExtraLabelsForButton:self.num8_Feb_Button];
	[self removeExtraLabelsForButton:self.num9_Mar_Button];
	[self removeExtraLabelsForButton:self.num4_Apr_Button];
	[self removeExtraLabelsForButton:self.num5_May_Button];
	[self removeExtraLabelsForButton:self.num6_Jun_Button];
	[self removeExtraLabelsForButton:self.num1_Jul_Button];
	[self removeExtraLabelsForButton:self.num2_Aug_Button];
	[self removeExtraLabelsForButton:self.num3_Sep_Button];
	[self removeExtraLabelsForButton:self.today_Oct_Button];
	[self removeExtraLabelsForButton:self.num0_Nov_Button];
	[self removeExtraLabelsForButton:self.delete_Dec_Button];
}

@end

//
//  A3NumberKeyboardViewController_iPad.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 12/21/12.
//  Copyright (c) 2012 ALLABOUTAPPS. All rights reserved.
//

#import "A3NumberKeyboardViewController_iPad.h"
#import "A3KeyboardMoveMarkView.h"

@interface A3NumberKeyboardViewController_iPad ()

@property (nonatomic, strong) IBOutlet A3KeyboardMoveMarkView *markView;

@end

@implementation A3NumberKeyboardViewController_iPad

@dynamic bigButton1;
@dynamic bigButton2;
@dynamic dotButton;
@dynamic prevButton;
@dynamic nextButton;
@dynamic clearButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
	}
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];

	[self reloadPrevNextButtons];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillLayoutSubviews {
	[self rotateToInterfaceOrientation:self.view.window.windowScene.interfaceOrientation];
}

- (void)setupFonts:(BOOL)portrait {
	[self.dotButton.titleLabel setFont:[UIFont systemFontOfSize:portrait ? 28 : 33]];

	NSMutableArray *numbers = [@[_num0Button, _num1Button, _num2Button, _num3Button, _num4Button, _num5Button, _num6Button, _num7Button, _num8Button, _num9Button] mutableCopy];
	if (self.bigButton1) {
		[numbers addObject:self.bigButton1];
	}
	if (self.bigButton2) {
		[numbers addObject:self.bigButton2];
	}
	
	[numbers enumerateObjectsUsingBlock:^(UIButton *button, NSUInteger idx, BOOL *stop) {
		button.titleLabel.font = [UIFont systemFontOfSize:portrait ? 22 : 27];
	}];

	NSMutableArray *functionButtons = [NSMutableArray new];
	if (self.clearButton) {
		[functionButtons addObject:self.clearButton];
	}
	if (self.doneButton) {
		[functionButtons addObject:self.doneButton];
	}
	if (self.prevButton) {
		[functionButtons addObject:self.prevButton];
	}
	if (self.nextButton) {
		[functionButtons addObject:self.nextButton];
	}
	[functionButtons enumerateObjectsUsingBlock:^(UIButton *button, NSUInteger idx, BOOL *stop) {
		button.titleLabel.font = [UIFont systemFontOfSize:portrait ? 18 : 25];
	}];

	if (self.plusMinusButton) {
		UIImage *image = [UIImage imageNamed:portrait ? @"minus_p" : @"minus_h"];
		[self.plusMinusButton setImage:image forState:UIControlStateNormal];
	}
}

- (void)rotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
	CGRect bounds = [A3UIDevice screenBoundsAdjustedWithOrientation];

	CGFloat col_1, col_2, col_3, col_4, col_5;
	CGFloat row_1, row_2, row_3, row_4;
	CGFloat width_small, height_small, width_big, height_big;
	if ([UIWindow interfaceOrientationIsPortrait]) {
		CGFloat scaleX = bounds.size.height != 1024 ? bounds.size.width / 768 : 1.0;
		CGFloat scaleY = bounds.size.height != 1024 ? 1.22 : 1.0;
        width_big = 124.0 * scaleX; height_big = 118.0 * scaleY + (scaleY != 1.0 ? 4 : 0);
        width_small = 89.0 * scaleX; height_small = 57.0 * scaleY;
		col_1 = 74.0 * scaleX; col_2 = 237.0 * scaleX; col_3 = 338.0 * scaleX; col_4 = 440.0 * scaleX; col_5 = 570.0 * scaleX;
		row_1 = 7.0 * scaleY; row_2 = 72.0 * scaleY; row_3 = 137.0 * scaleY; row_4 = 201.0 * scaleY;

		[_markView setFrame:CGRectMake(755.0 * scaleX, 219.0 * scaleY, 8.0 * scaleX, 24.0 * scaleY)];
	} else {
		CGFloat scaleX = bounds.size.height != 768 ? bounds.size.height / 768 : 1.0;
		CGFloat scaleY = bounds.size.height != 768 ? 1.16 : 1.0;
        width_big = 172.0 * scaleX; height_big = 164.0 * scaleY;
        width_small = 108.0 * scaleX; height_small = 77.0 * scaleY;
		col_1 = 114.0 * scaleX; col_2 = 332.0 * scaleX; col_3 = 455.0 * scaleX; col_4 = 578.0 * scaleX; col_5 = 735.0 * scaleX;
		row_1 = 8.0 * scaleY; row_2 = 94.0 * scaleY; row_3 = 179.0 * scaleY; row_4 = 265.0 * scaleY;

		[_markView setFrame:CGRectMake(999.0 * scaleX, 282.0 * scaleY, 10.0 * scaleX, 24.0 * scaleY)];
	}
	[self.bigButton1 setFrame:CGRectMake(col_1, row_1, width_big, height_big)];
	[self.bigButton2 setFrame:CGRectMake(col_1, row_3, width_big, height_big)];

	[_num7Button setFrame:CGRectMake(col_2, row_1, width_small, height_small)];
	[_num8Button setFrame:CGRectMake(col_3, row_1, width_small, height_small)];
	[_num9Button setFrame:CGRectMake(col_4, row_1, width_small, height_small)];

	[_num4Button setFrame:CGRectMake(col_2, row_2, width_small, height_small)];
	[_num5Button setFrame:CGRectMake(col_3, row_2, width_small, height_small)];
	[_num6Button setFrame:CGRectMake(col_4, row_2, width_small, height_small)];

	[_num1Button setFrame:CGRectMake(col_2, row_3, width_small, height_small)];
	[_num2Button setFrame:CGRectMake(col_3, row_3, width_small, height_small)];
	[_num3Button setFrame:CGRectMake(col_4, row_3, width_small, height_small)];

	[self.clearButton setFrame:CGRectMake(col_2, row_4, width_small, height_small)];
	[_num0Button setFrame:CGRectMake(col_3, row_4, width_small, height_small)];
	[self.dotButton setFrame:CGRectMake(col_4, row_4, width_small, height_small)];

	[self.deleteButton setFrame:CGRectMake(col_5, row_1, width_big, height_small)];
	[self.prevButton setFrame:CGRectMake(col_5, row_2, width_big, height_small)];
	[self.nextButton setFrame:CGRectMake(col_5, row_3, width_big, height_small)];
	[self.doneButton setFrame:CGRectMake(col_5, row_4, width_big, height_small)];

	[self setupFonts:[UIWindow interfaceOrientationIsPortrait] ];
}

@end

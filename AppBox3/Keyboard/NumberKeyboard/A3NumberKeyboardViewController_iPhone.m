//
//  A3NumberKeyboardViewController_iPhone.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 4/9/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import "A3NumberKeyboardViewController_iPhone.h"
#import "A3KeyboardButton_iOS7_iPhone.h"

@interface A3NumberKeyboardViewController_iPhone ()

@property (nonatomic, weak) IBOutlet A3KeyboardButton_iOS7_iPhone *num1Button;
@property (nonatomic, weak) IBOutlet A3KeyboardButton_iOS7_iPhone *num2Button;
@property (nonatomic, weak) IBOutlet A3KeyboardButton_iOS7_iPhone *num3Button;
@property (nonatomic, weak) IBOutlet A3KeyboardButton_iOS7_iPhone *num4Button;
@property (nonatomic, weak) IBOutlet A3KeyboardButton_iOS7_iPhone *num5Button;
@property (nonatomic, weak) IBOutlet A3KeyboardButton_iOS7_iPhone *num6Button;
@property (nonatomic, weak) IBOutlet A3KeyboardButton_iOS7_iPhone *num7Button;
@property (nonatomic, weak) IBOutlet A3KeyboardButton_iOS7_iPhone *num8Button;
@property (nonatomic, weak) IBOutlet A3KeyboardButton_iOS7_iPhone *num9Button;
@property (nonatomic, weak) IBOutlet A3KeyboardButton_iOS7_iPhone *num0Button;
@property (nonatomic, weak) IBOutlet A3KeyboardButton_iOS7_iPhone *doneButton;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *bottomSpaceConstraint;

@end

@implementation A3NumberKeyboardViewController_iPhone

@dynamic dotButton;
@dynamic prevButton, nextButton, clearButton, doneButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _needButtonsReload = YES;
    }
    return self;
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	// Do any additional setup after loading the view from its nib.

    UIEdgeInsets safeAreaInsets = [[[UIApplication sharedApplication] myKeyWindow] safeAreaInsets];
    if (safeAreaInsets.top > 20) {
        _bottomSpaceConstraint.constant = safeAreaInsets.bottom;
    }
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];

    if (_needButtonsReload) {
		[self reloadPrevNextButtons];
	}
}

- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

@end

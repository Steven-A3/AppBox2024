//
//  A3AbbreviationHelpViewController.m
//  AppBox3
//
//  Created by Byeong-Kwon Kwak on 2/15/17.
//  Copyright © 2017 ALLABOUTAPPS. All rights reserved.
//

#import "A3AbbreviationHelpViewController.h"
#import "A3AppDelegate.h"

@interface A3AbbreviationHelpViewController ()

@property (nonatomic, strong) IBOutletCollection(UIImageView) NSArray<UIImageView *> *imageViews;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *topSpaceConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *topLeadingConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *bottomLeadingConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *bottomSpaceConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *imageWidthConstraint;
@property (nonatomic, strong) IBOutlet NSLayoutConstraint *imageHPositionConstraint;
@property (nonatomic, weak) IBOutlet UIImageView *popoverImageView;
@property (nonatomic, weak) IBOutlet UIImageView *fingerUpImageView;

@end

@implementation A3AbbreviationHelpViewController

+ (instancetype)storyboardInstance {
	UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Abbreviation" bundle:nil];
	A3AbbreviationHelpViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:NSStringFromClass([self class])];
	return viewController;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
	
	for (UIImageView *imageView in _imageViews) {
		imageView.tintColor = [[A3AppDelegate instance] themeColor];
	}
}

- (void)viewWillLayoutSubviews {
	if (IS_IPHONE_4_7_INCH) {
		_imageWidthConstraint.constant = 240;
		_topSpaceConstraint.constant = 190;
		_bottomSpaceConstraint.constant = 40;
	} else if (IS_IPHONE_4_INCH) {
		_imageWidthConstraint.constant = 160;
		_topSpaceConstraint.constant = 160;
		_bottomSpaceConstraint.constant = 30;
		_topLeadingConstraint.constant = 50; // 82 iPhone 7 Plus
		_bottomLeadingConstraint.constant = 110; // 165 iPhone 7 Plus
	} else if (IS_IPHONE_3_5_INCH) {
		_imageWidthConstraint.constant = 130;
		_topSpaceConstraint.constant = 140;
		_bottomSpaceConstraint.constant = 30;
		_topLeadingConstraint.constant = 50; // 82 iPhone 7 Plus
		_bottomLeadingConstraint.constant = 50; // 165 iPhone 7 Plus
	} else if (IS_IPAD_12_9_INCH) {
		_topSpaceConstraint.constant = 240;
		_bottomSpaceConstraint.constant = 100;
		_topLeadingConstraint.constant = 60; // 82 iPhone 7 Plus
		_bottomLeadingConstraint.constant = 150; // 165 iPhone 7 Plus
		
		[self.view removeConstraint:_imageHPositionConstraint];
		_imageHPositionConstraint = [NSLayoutConstraint constraintWithItem:_popoverImageView
																 attribute:NSLayoutAttributeLeading
																 relatedBy:NSLayoutRelationEqual
																	toItem:_fingerUpImageView
																 attribute:NSLayoutAttributeLeading
																multiplier:1.0 constant:0];
		[self.view addConstraint:_imageHPositionConstraint];
		
	} else if (IS_IPAD) {
		_topSpaceConstraint.constant = 200;
		_bottomSpaceConstraint.constant = 100;
		_topLeadingConstraint.constant = 50; // 82 iPhone 7 Plus
		_bottomLeadingConstraint.constant = 140; // 165 iPhone 7 Plus

		[self.view removeConstraint:_imageHPositionConstraint];
		_imageHPositionConstraint = [NSLayoutConstraint constraintWithItem:_popoverImageView
																 attribute:NSLayoutAttributeLeading
																 relatedBy:NSLayoutRelationEqual
																	toItem:_fingerUpImageView
																 attribute:NSLayoutAttributeLeading
																multiplier:1.0 constant:0];
		[self.view addConstraint:_imageHPositionConstraint];
}
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

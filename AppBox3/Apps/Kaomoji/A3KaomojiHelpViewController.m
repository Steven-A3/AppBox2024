//
//  A3KaomojiHelpViewController.m
//  AppBox3
//
//  Created by Byeong-Kwon Kwak on 2017. 2. 21..
//  Copyright © 2017년 ALLABOUTAPPS. All rights reserved.
//

#import "A3KaomojiHelpViewController.h"
#import "A3AppDelegate.h"

@interface A3KaomojiHelpViewController ()

@property (nonatomic, strong) IBOutletCollection(UIImageView) NSArray<UIImageView *> *imageViews;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *topSpaceConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *topLeadingConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *imageWidthConstraint;

@end

@implementation A3KaomojiHelpViewController

+ (instancetype)storyboardInstance {
	UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Kaomoji" bundle:nil];
	A3KaomojiHelpViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:NSStringFromClass([self class])];
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
		_topSpaceConstraint.constant = 190;
	} else if (IS_IPHONE_4_INCH) {
		_topSpaceConstraint.constant = 165;
	} else if (IS_IPHONE_3_5_INCH) {
		_topSpaceConstraint.constant = 140;
	} else if (IS_IPAD_12_9_INCH) {
	} else if (IS_IPAD) {

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

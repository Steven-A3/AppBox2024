//
//  A3DrillDownHelpViewController.m
//  AppBox3
//
//  Created by Byeong-Kwon Kwak on 2017. 2. 21..
//  Copyright © 2017년 ALLABOUTAPPS. All rights reserved.
//

#import "A3DrillDownHelpViewController.h"
#import "A3AppDelegate.h"

@interface A3DrillDownHelpViewController ()

@property (nonatomic, strong) IBOutletCollection(UIImageView) NSArray<UIImageView *> *imageViews;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *topSpaceConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *topLeadingConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *imageWidthConstraint;
@property (nonatomic, weak) IBOutlet UIImageView *popupImageView;

@end

@implementation A3DrillDownHelpViewController

+ (instancetype)storyboardInstance {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Abbreviation" bundle:nil];
    A3DrillDownHelpViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:NSStringFromClass([self class])];
    return viewController;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    for (UIImageView *imageView in _imageViews) {
        imageView.tintColor = [[A3AppDelegate instance] themeColor];
    }
    _popupImageView.image = [UIImage imageNamed:_imageName];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillLayoutSubviews {
	if (IS_IPHONE_4_7_INCH) {
		_topSpaceConstraint.constant = 150;
	} else if (IS_IPHONE_4_INCH) {
		_topSpaceConstraint.constant = 127;
	} else if (IS_IPHONE_3_5_INCH) {
		_topSpaceConstraint.constant = 107;
	} else if (IS_IPAD_12_9_INCH) {
	} else if (IS_IPAD) {
		_topSpaceConstraint.constant = 145;
	}
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

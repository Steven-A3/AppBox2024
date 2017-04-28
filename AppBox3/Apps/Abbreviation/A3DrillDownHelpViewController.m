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
@property (nonatomic, strong) IBOutlet NSLayoutConstraint *imageHPositionConstraint;
@property (nonatomic, weak) IBOutlet UIImageView *fingerUpImageView;
@property (nonatomic, weak) IBOutlet UILabel *helpLabel;

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
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"10") && self.traitCollection.forceTouchCapability == UIForceTouchCapabilityAvailable)
    {
        _helpLabel.text = NSLocalizedString(@"DrillHelpTapToCopyOrPress", nil);
    }
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
        _imageWidthConstraint.constant = 130;
		_topSpaceConstraint.constant = 107;
	} else if (IS_IPAD_12_9_INCH) {
		_topSpaceConstraint.constant = 165;
		[self replacePopoverImageHPositionConstraint];
	} else if (IS_IPAD) {
		_topSpaceConstraint.constant = 145;
		[self replacePopoverImageHPositionConstraint];
	}
}

- (void)replacePopoverImageHPositionConstraint {
	[self.view removeConstraint:_imageHPositionConstraint];
	_imageHPositionConstraint = [NSLayoutConstraint constraintWithItem:_popupImageView
															 attribute:NSLayoutAttributeLeading
															 relatedBy:NSLayoutRelationEqual
																toItem:_fingerUpImageView
															 attribute:NSLayoutAttributeLeading
															multiplier:1.0
															  constant:0.0];
	[self.view addConstraint:_imageHPositionConstraint];
}

@end

//
//  A3WhatsNew4_5ViewController.m
//  AppBox3
//
//  Created by Byeong-Kwon Kwak on 2/15/17.
//  Copyright © 2017 ALLABOUTAPPS. All rights reserved.
//

#import "A3WhatsNew4_5ViewController.h"
#import "FXBlurView.h"
#import "A3AppDelegate.h"

@interface A3WhatsNew4_5ViewController ()

@property (nonatomic, weak) IBOutlet NSLayoutConstraint *topSpaceConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *titleVerticalSpaceConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *imageVerticalSpaceConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *centerHorizontalSpaceConstraint;
@property (nonatomic, strong) UIView *snapshotView;
@property (nonatomic, strong) IBOutletCollection(UILabel) NSArray<UILabel *> *contentLabels;
@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UILabel *subtitleLabel;
@property (nonatomic, weak) IBOutlet UIImageView *abbreviationImageView;
@property (nonatomic, weak) IBOutlet UIImageView *kaomojiImageView;
@property (nonatomic, strong) IBOutlet NSLayoutConstraint *abbreviationImageWidthConstraint;
@property (nonatomic, strong) IBOutlet NSLayoutConstraint *kaomojiImageWidthConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *abbreviationDescriptionTopConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *kaomojiDescriptionTopConstraint;
@property (nonatomic, strong) IBOutlet NSLayoutConstraint *descriptionLeadingConstraint;
@property (nonatomic, weak) IBOutlet UILabel *firstDescriptionLabel;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *bottomDescriptionVerticalSpaceConstraint;
@property (nonatomic, weak) IBOutlet UIButton *abbreviationButton;
@property (nonatomic, weak) IBOutlet UIButton *kaomojiButton;
@property (nonatomic, strong) IBOutletCollection(NSLayoutConstraint) NSArray<NSLayoutConstraint *> *interDescriptionVSpaceConstraints;

@end

@implementation A3WhatsNew4_5ViewController

+ (instancetype)storyboardInstanceWithSnapshotView:(UIView *)snapshotView {
    A3WhatsNew4_5ViewController *viewController = [[UIStoryboard storyboardWithName:@"WhatsNew4_5" bundle:nil] instantiateInitialViewController];
    viewController.snapshotView = snapshotView;
    return viewController;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

	if (_snapshotView) {
		self.view.backgroundColor = [UIColor clearColor];
		_snapshotView.frame = self.view.bounds;
		_snapshotView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		[self.view insertSubview:_snapshotView atIndex:0];
	}

	[[UIApplication sharedApplication] setStatusBarHidden:YES];

	if (SYSTEM_VERSION_LESS_THAN(@"8.0")) {
		_abbreviationImageView.image = [UIImage imageNamed:@"Abbreviation"];
		_kaomojiImageView.image = [UIImage imageNamed:@"Kaomoji"];
	}
}

- (void)viewWillLayoutSubviews {
	[self setupLayoutAttributes];
}

- (void)setupLayoutAttributes {
	if (IS_IPHONE_3_5_INCH) {
		_topSpaceConstraint.constant = 30;
		_titleVerticalSpaceConstraint.constant = 15;
		_imageVerticalSpaceConstraint.constant = 40;

		_titleLabel.font = [UIFont systemFontOfSize:20];
		_subtitleLabel.font = [UIFont systemFontOfSize:18];
		[self setContentsFont:[UIFont systemFontOfSize:14]];
		_abbreviationDescriptionTopConstraint.constant = 20;
		_kaomojiDescriptionTopConstraint.constant = 18;
		_bottomDescriptionVerticalSpaceConstraint.constant = 30;
	} else if (IS_IPHONE_4_INCH) {
		_topSpaceConstraint.constant = 50;
		_centerHorizontalSpaceConstraint.constant = 15;
		_imageVerticalSpaceConstraint.constant = 50;
		_abbreviationDescriptionTopConstraint.constant = 20;
		_kaomojiDescriptionTopConstraint.constant = 18;
		[self setInterDescriptionVSpace:20];
	} else if (IS_IPHONE_4_7_INCH) {
		_topSpaceConstraint.constant = 50;
		_imageVerticalSpaceConstraint.constant = 90;
		[self setContentsFont:[UIFont systemFontOfSize:17]];
		_abbreviationDescriptionTopConstraint.constant = 22;
		_kaomojiDescriptionTopConstraint.constant = 22;
		[self setInterDescriptionVSpace:25];
	} else if (IS_IPHONE_5_5_INCH) {
		_topSpaceConstraint.constant = 60;
		_imageVerticalSpaceConstraint.constant = 110;
		
		[self setContentsFont:[UIFont systemFontOfSize:19]];
		_abbreviationDescriptionTopConstraint.constant = 25;
		_kaomojiDescriptionTopConstraint.constant = 25;
		
		[self setInterDescriptionVSpace:28];
		
	} else if (IS_IPAD_12_9_INCH) {
		_topSpaceConstraint.constant = IS_PORTRAIT ? 200 : 50;
		_imageVerticalSpaceConstraint.constant = IS_PORTRAIT ? 50 : 10;
		_centerHorizontalSpaceConstraint.constant = 50;

		[self setImageSizeForiPad];
		
		_titleLabel.font = [UIFont systemFontOfSize:40];
		_subtitleLabel.font = [UIFont systemFontOfSize:35];
		[self setContentsFont:[UIFont systemFontOfSize:30]];

		[self setInterDescriptionVSpace:30];

		_abbreviationDescriptionTopConstraint.constant = 100;
		_kaomojiDescriptionTopConstraint.constant = 100;
		
		_abbreviationButton.titleLabel.font = [UIFont systemFontOfSize:25];
		_kaomojiButton.titleLabel.font = [UIFont systemFontOfSize:25];
	} else if (IS_IPAD) {
		_topSpaceConstraint.constant = IS_PORTRAIT ? 100 : 30;
		_imageVerticalSpaceConstraint.constant = IS_PORTRAIT ? 70 : 10;

		[self setImageSizeForiPad];

		_titleLabel.font = [UIFont systemFontOfSize:30];
		_subtitleLabel.font = [UIFont systemFontOfSize:28];
		[self setContentsFont:[UIFont systemFontOfSize:24]];

		[self setInterDescriptionVSpace:30];
		
		_abbreviationDescriptionTopConstraint.constant = 60;
		_kaomojiDescriptionTopConstraint.constant = 60;
		
		_abbreviationButton.titleLabel.font = [UIFont systemFontOfSize:20];
		_kaomojiButton.titleLabel.font = [UIFont systemFontOfSize:20];
	}
}

- (void)setContentsFont:(UIFont *)contentFont {
	for (UILabel *label in _contentLabels) {
		label.font = contentFont;
	}
}

- (void)setInterDescriptionVSpace:(CGFloat)space {
	for (NSLayoutConstraint *vspace in _interDescriptionVSpaceConstraints) {
		vspace.constant = space;
	}
}

- (void)setImageSizeForiPad {
	[self.view removeConstraints:@[_abbreviationImageWidthConstraint, _kaomojiImageWidthConstraint]];
	CGFloat imageSize = SCREEN_MIN_LENGTH * 0.3;
	_abbreviationImageWidthConstraint = [NSLayoutConstraint constraintWithItem:_abbreviationImageView
																	 attribute:NSLayoutAttributeWidth
																	 relatedBy:NSLayoutRelationEqual
																		toItem:nil
																	 attribute:NSLayoutAttributeNotAnAttribute
																	multiplier:1.0
																	  constant:imageSize];
	_kaomojiImageWidthConstraint = [NSLayoutConstraint constraintWithItem:_kaomojiImageView
																attribute:NSLayoutAttributeWidth
																relatedBy:NSLayoutRelationEqual
																   toItem:nil
																attribute:NSLayoutAttributeNotAnAttribute
															   multiplier:1.0
																 constant:imageSize];
	[self.view addConstraints:@[_abbreviationImageWidthConstraint, _kaomojiImageWidthConstraint]];
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
- (IBAction)openAbbreviationApp:(id)sender {
	[[UIApplication sharedApplication] setStatusBarHidden:NO];
    [self dismissViewControllerAnimated:NO completion:NULL];
    [[A3AppDelegate instance] launchAppNamed:A3AppName_Abbreviation verifyPasscode:YES animated:YES];
    [[A3AppDelegate instance] updateRecentlyUsedAppsWithAppName:A3AppName_Abbreviation];
}

- (IBAction)openKaomojiApp:(id)sender {
	[[UIApplication sharedApplication] setStatusBarHidden:NO];
    [self dismissViewControllerAnimated:NO completion:NULL];
    [[A3AppDelegate instance] launchAppNamed:A3AppName_Kaomoji verifyPasscode:YES animated:YES];
    [[A3AppDelegate instance] updateRecentlyUsedAppsWithAppName:A3AppName_Kaomoji];
}

- (IBAction)didTapOnTheMainView:(id)sender {
	[[UIApplication sharedApplication] setStatusBarHidden:NO];
	[self dismissViewControllerAnimated:YES completion:NULL];
}

@end

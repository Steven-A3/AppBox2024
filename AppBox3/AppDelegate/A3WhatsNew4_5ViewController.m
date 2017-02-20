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

}

- (void)viewWillLayoutSubviews {
	[self setupLayoutAttributes];
}

- (void)setupLayoutAttributes {
	if (IS_IPHONE_3_5_INCH) {
		_titleVerticalSpaceConstraint.constant = 10;
		_imageVerticalSpaceConstraint.constant = 80;

		_titleLabel.font = [UIFont fontWithName:@"MarkerFelt-Thin" size:20];
		_subtitleLabel.font = [UIFont fontWithName:@"MarkerFelt-Thin" size:18];
		UIFont *contentFont = [UIFont fontWithName:@"Copperplate-Bold" size:13];
		for (UILabel *label in _contentLabels) {
			label.font = contentFont;
		}
	}
	if (IS_IPHONE_4_INCH || IS_IPHONE_3_5_INCH) {
		_centerHorizontalSpaceConstraint.constant = 15;
		_imageVerticalSpaceConstraint.constant = 130;
	} else if (IS_IPHONE_4_7_INCH) {
		_topSpaceConstraint.constant = 50;
		_imageVerticalSpaceConstraint.constant = 150;
		UIFont *contentFont = [UIFont fontWithName:@"MarkerFelt-Wide" size:17];
		for (UILabel *label in _contentLabels) {
			label.font = contentFont;
		}
	} else if (IS_IPHONE_5_5_INCH) {
		_topSpaceConstraint.constant = 60;
		_imageVerticalSpaceConstraint.constant = 170;
		
		UIFont *contentFont = [UIFont fontWithName:@"MarkerFelt-Wide" size:19];
		for (UILabel *label in _contentLabels) {
			label.font = contentFont;
		}
	} else if (IS_IPAD_12_9_INCH) {
		_topSpaceConstraint.constant = IS_PORTRAIT ? 200 : 50;
		_imageVerticalSpaceConstraint.constant = IS_PORTRAIT ? 50 : 10;
		_centerHorizontalSpaceConstraint.constant = 50;
		
		[self.view removeConstraints:@[_descriptionLeadingConstraint, _abbreviationImageWidthConstraint, _kaomojiImageWidthConstraint]];
		_descriptionLeadingConstraint = [NSLayoutConstraint constraintWithItem:_firstDescriptionLabel
																	 attribute:NSLayoutAttributeLeading
																	 relatedBy:NSLayoutRelationEqual
																		toItem:self.view
																	 attribute:NSLayoutAttributeTrailing
																	multiplier:0.5
																	  constant:0];
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

		[self.view addConstraints:@[_descriptionLeadingConstraint, _abbreviationImageWidthConstraint, _kaomojiImageWidthConstraint]];
		
		_titleLabel.font = [UIFont systemFontOfSize:40];
		_subtitleLabel.font = [UIFont systemFontOfSize:35];
		UIFont *contentFont = [UIFont systemFontOfSize:30];
		for (UILabel *label in _contentLabels) {
			label.font = contentFont;
		}
		
		_abbreviationDescriptionTopConstraint.constant = 100;
		_kaomojiDescriptionTopConstraint.constant = 100;
		
		_abbreviationButton.titleLabel.font = [UIFont systemFontOfSize:20];
		_kaomojiButton.titleLabel.font = [UIFont systemFontOfSize:20];
	} else if (IS_IPAD) {
		_topSpaceConstraint.constant = 70;
		_imageVerticalSpaceConstraint.constant = 50;
		
		[self.view removeConstraints:@[_descriptionLeadingConstraint, _abbreviationImageWidthConstraint, _kaomojiImageWidthConstraint]];
		_descriptionLeadingConstraint = [NSLayoutConstraint constraintWithItem:_firstDescriptionLabel
																	 attribute:NSLayoutAttributeLeading
																	 relatedBy:NSLayoutRelationEqual
																		toItem:self.view
																	 attribute:NSLayoutAttributeTrailing
																	multiplier:0.5
																	  constant:0];
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
		[self.view addConstraints:@[_descriptionLeadingConstraint, _abbreviationImageWidthConstraint, _kaomojiImageWidthConstraint]];

		_titleLabel.font = [UIFont systemFontOfSize:30];
		_subtitleLabel.font = [UIFont systemFontOfSize:28];
		UIFont *contentFont = [UIFont systemFontOfSize:24];
		for (UILabel *label in _contentLabels) {
			label.font = contentFont;
		}
		
		_abbreviationDescriptionTopConstraint.constant = 60;
		_kaomojiDescriptionTopConstraint.constant = 60;
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

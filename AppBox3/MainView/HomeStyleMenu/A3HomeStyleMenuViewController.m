//
//  A3HomeStyleMenuViewController.m
//  HexagonMenu
//
//  Created by Byeong Kwon Kwak on 2/26/16.
//  Copyright © 2016 ALLABOUTAPPS. All rights reserved.
//

#import "A3AppDelegate.h"
#import "A3HexagonMenuViewController.h"

@interface A3HomeStyleMenuViewController ()

@end

@implementation A3HomeStyleMenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

	self.automaticallyAdjustsScrollViewInsets = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
	
	UINavigationController *navigationController = self.navigationController;
	[navigationController setNavigationBarHidden:YES animated:NO];

	UIImage *image = [UIImage new];
	[navigationController.navigationBar setBackgroundImage:image forBarMetrics:UIBarMetricsDefault];
	[navigationController.navigationBar setShadowImage:image];

	[super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];

	self.activeAppName = nil;
	FNLOG(@"activeAppName = nil");
	
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

- (UIView *)backgroundView {
	UIView *backgroundView = [UIView new];
	// 56	63	73
	backgroundView.backgroundColor = [UIColor colorWithRed:56.0/255.0 green:63.0/255.0 blue:74.0/255.0 alpha:1.0];

	CGRect screenBounds = [A3UIDevice screenBoundsAdjustedWithOrientation];

	UIButton *helpButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[helpButton addTarget:self action:@selector(helpButtonAction:) forControlEvents:UIControlEventTouchUpInside];
	[helpButton setBackgroundImage:[[UIImage imageNamed:@"help"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
	helpButton.tintColor = [UIColor whiteColor];

	[backgroundView addSubview:helpButton];

	UIView *superview = backgroundView;
	[helpButton mas_makeConstraints:^(MASConstraintMaker *make) {
		make.left.equalTo(superview.left).with.offset(15);
		make.top.equalTo(superview.top).with.offset(30);
		make.width.equalTo(screenBounds.size.height <= 568 ? @30 : @35);
		make.height.equalTo(screenBounds.size.height <= 568 ? @30 : @35);
	}];

	UIButton *settingsButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[settingsButton setBackgroundImage:[[UIImage imageNamed:@"general"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
	[settingsButton addTarget:self action:@selector(settingsButtonAction:) forControlEvents:UIControlEventTouchUpInside];
	settingsButton.tintColor = [UIColor whiteColor];
	[backgroundView addSubview:settingsButton];

	[settingsButton makeConstraints:^(MASConstraintMaker *make) {
		make.top.equalTo(superview.top).with.offset(30);
		make.right.equalTo(superview.right).with.offset(-15);
		make.width.equalTo(screenBounds.size.height <= 568 ? @30 : @35);
		make.height.equalTo(screenBounds.size.height <= 568 ? @30 : @35);
	}];

	UILabel *titleLabel = [UILabel new];
	titleLabel.text = @"AppBox Pro®";
	titleLabel.textColor = [UIColor whiteColor];
	titleLabel.font = [UIFont systemFontOfSize:screenBounds.size.height <= 568 ? 22 : 26];
	titleLabel.textAlignment = NSTextAlignmentCenter;
	[backgroundView addSubview:titleLabel];

	[titleLabel makeConstraints:^(MASConstraintMaker *make) {
		make.centerX.equalTo(superview.centerX);
		make.top.equalTo(superview.top).with.offset(32);
	}];

	if (screenBounds.size.height > 568) {
		[self addAppLinkButtonToView:backgroundView title:@"AppBox" imageName:@"iPad_AppBox" position:IS_IPHONE ? 0.2 : 0.25 selector:@selector(openAppStoreAppBox)];
		[self addAppLinkButtonToView:backgroundView title:@"Numpad" imageName:@"iPad_Numpad" position:0.5 selector:@selector(openAppStoreNumpad)];
		[self addAppLinkButtonToView:backgroundView title:@"Moment" imageName:@"iPad_Moment" position:IS_IPHONE ? 0.8 : 0.75 selector:@selector(openAppStoreMoment)];
	} else {
		[self addAppLinkButtonToView:backgroundView title:@"AppBox" imageName:@"iPhone_AppBox" position:0.25 selector:@selector(openAppStoreAppBox)];
		[self addAppLinkButtonToView:backgroundView title:@"Numpad" imageName:@"iPhone_Numpad" position:0.5 selector:@selector(openAppStoreNumpad)];
		[self addAppLinkButtonToView:backgroundView title:@"Moment" imageName:@"iPhone_Moment" position:0.75 selector:@selector(openAppStoreMoment)];
	}

	return backgroundView;
}

- (void)settingsButtonAction:(UIButton *)button {
	if (![[A3AppDelegate instance] launchAppNamed:A3AppName_Settings verifyPasscode:YES delegate:self animated:YES]) {
		self.selectedAppName = A3AppName_Settings;
	}
}

- (void)helpButtonAction:(id)sender {
	[[A3AppDelegate instance] launchAppNamed:A3AppName_About verifyPasscode:NO delegate:nil animated:YES];
}

- (void)addAppLinkButtonToView:(UIView *)targetView title:(NSString *)title imageName:(NSString *)imageName position:(CGFloat)position selector:(SEL)selector {
	CGRect screenBounds = [A3UIDevice screenBoundsAdjustedWithOrientation];
	
	UILabel *appTitle = [UILabel new];
	appTitle.textColor = [UIColor whiteColor];
	appTitle.font = [UIFont systemFontOfSize:IS_IPHONE ? 11 : 13];
	appTitle.text = title;
	appTitle.textAlignment = NSTextAlignmentCenter;
	[targetView addSubview:appTitle];

	[appTitle makeConstraints:^(MASConstraintMaker *make) {
		make.centerX.equalTo(targetView.right).with.multipliedBy(position);
		make.bottom.equalTo(targetView.bottom).with.offset(screenBounds.size.height == 480 ? -5 : -15);
	}];

	UIButton *appButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[appButton setBackgroundImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
	[targetView addSubview:appButton];

	[appButton makeConstraints:^(MASConstraintMaker *make) {
		make.centerX.equalTo(targetView.right).with.multipliedBy(position);
		make.bottom.equalTo(appTitle.top).with.offset(-4);
	}];

	if (selector) {
		[appButton addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
	}
}

- (UIStatusBarStyle)preferredStatusBarStyle {
	[self setNeedsStatusBarAppearanceUpdate];
	return UIStatusBarStyleLightContent;
}

- (void)openAppStoreAppBox {
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"itms-apps://itunes.apple.com/app/id307094023"]];
}

- (void)openAppStoreMoment {
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"itms-apps://itunes.apple.com/app/id998244903"]];
}

- (void)openAppStoreNumpad {
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"itms-apps://itunes.apple.com/app/id967194299"]];
}

- (void)passcodeViewControllerDidDismissWithSuccess:(BOOL)success {
	if (success && _selectedAppName) {
		[[A3AppDelegate instance] launchAppNamed:_selectedAppName verifyPasscode:NO delegate:nil animated:YES];
		self.activeAppName = [_selectedAppName copy];
	}
	_selectedAppName = nil;
}

@end

//
//  A3HomeStyleMenuViewController.m
//  HexagonMenu
//
//  Created by Byeong Kwon Kwak on 2/26/16.
//  Copyright © 2016 ALLABOUTAPPS. All rights reserved.
//

#import "A3AppDelegate.h"
#import "A3HexagonMenuViewController.h"
#import "A3HomeScreenButton.h"
#import "MMDrawerController.h"
#import "UIViewController+A3Addition.h"
#import "RMAppReceipt.h"

@interface A3HomeStyleMenuViewController ()

@end

@implementation A3HomeStyleMenuViewController {
	BOOL _initialized;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

	self.automaticallyAdjustsScrollViewInsets = NO;

	RMAppReceipt *appReceipt = [A3AppDelegate instance].appReceipt;
	if ([appReceipt verifyReceiptHash] && [[A3AppDelegate instance] isIAPPurchasedCustomer:appReceipt]) {
		_shouldShowHouseAd = NO;
	} else {
		_shouldShowHouseAd = YES;
	}
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];

	if (!_initialized) {
		_initialized = YES;
		UINavigationController *navigationController = self.navigationController;
		
		UIImage *image = [UIImage new];
		[navigationController.navigationBar setBackgroundImage:image forBarMetrics:UIBarMetricsDefault];
		[navigationController.navigationBar setShadowImage:image];
	}

	[super viewWillAppear:animated];
}

- (UIView *)backgroundView {
	UIView *backgroundView = [UIView new];
	// 56	63	73
	backgroundView.backgroundColor = [UIColor colorWithRed:56.0/255.0 green:63.0/255.0 blue:74.0/255.0 alpha:1.0];

	CGRect screenBounds = [A3UIDevice screenBoundsAdjustedWithOrientation];

	A3HomeScreenButton *helpButton = [A3HomeScreenButton buttonWithType:UIButtonTypeCustom];
	helpButton.tintColor = [UIColor whiteColor];
	[helpButton setIconNamed:@"help"];
	[helpButton addTarget:self action:@selector(helpButtonAction:) forControlEvents:UIControlEventTouchUpInside];
	[backgroundView addSubview:helpButton];

	UIView *superview = backgroundView;
	[helpButton mas_makeConstraints:^(MASConstraintMaker *make) {
		if (IS_IPAD_PRO) {
			make.top.equalTo(superview.top).with.offset(25);
			make.left.equalTo(superview.left).with.offset(20);
			make.width.equalTo(@50);
			make.height.equalTo(@50);
		} else {
			make.top.equalTo(superview.top).with.offset(23);
			make.left.equalTo(superview.left).with.offset(8);
			make.width.equalTo(@44);
			make.height.equalTo(@44);
		}
	}];

	A3HomeScreenButton *settingsButton = [A3HomeScreenButton buttonWithType:UIButtonTypeCustom];
	settingsButton.tintColor = [UIColor whiteColor];
	[settingsButton setIconNamed:@"general"];
	[settingsButton addTarget:self action:@selector(settingsButtonAction:) forControlEvents:UIControlEventTouchUpInside];
	[backgroundView addSubview:settingsButton];
	
	[settingsButton makeConstraints:^(MASConstraintMaker *make) {
		if (IS_IPAD_PRO) {
			make.top.equalTo(superview.top).with.offset(25);
			make.right.equalTo(superview.right).with.offset(-20);
			make.width.equalTo(@50);
			make.height.equalTo(@50);
		} else {
			make.top.equalTo(superview.top).with.offset(23);
			make.right.equalTo(superview.right).with.offset(-8);
			make.width.equalTo(@44);
			make.height.equalTo(@44);
		}
	}];

	UILabel *titleLabel = [UILabel new];
	titleLabel.text = @"AppBox Pro®";
	titleLabel.textColor = [UIColor whiteColor];
	CGFloat fontSize;
	if (IS_IPAD_PRO) {
		fontSize = 31;
	} else {
		fontSize = screenBounds.size.height <= 568 ? 22 : 26;
	}
	titleLabel.font = [UIFont systemFontOfSize:fontSize];
	titleLabel.textAlignment = NSTextAlignmentCenter;
	[backgroundView addSubview:titleLabel];

	[titleLabel makeConstraints:^(MASConstraintMaker *make) {
		make.centerX.equalTo(superview.centerX);
		make.top.equalTo(superview.top).with.offset(32);
	}];

	if (_shouldShowHouseAd) {
		if (screenBounds.size.height > 568) {
			[self addAppLinkButtonToView:backgroundView title:@"AppBox" imageName:@"iPad_AppBox" position:IS_IPHONE ? 0.2 : 0.25 selector:@selector(openAppStoreAppBox)];
			[self addAppLinkButtonToView:backgroundView title:@"Numpad" imageName:@"iPad_Numpad" position:0.5 selector:@selector(openAppStoreNumpad)];
			[self addAppLinkButtonToView:backgroundView title:@"Moment" imageName:@"iPad_Moment" position:IS_IPHONE ? 0.8 : 0.75 selector:@selector(openAppStoreMoment)];
		} else {
			[self addAppLinkButtonToView:backgroundView title:@"AppBox" imageName:@"iPhone_AppBox" position:0.25 selector:@selector(openAppStoreAppBox)];
			[self addAppLinkButtonToView:backgroundView title:@"Numpad" imageName:@"iPhone_Numpad" position:0.5 selector:@selector(openAppStoreNumpad)];
			[self addAppLinkButtonToView:backgroundView title:@"Moment" imageName:@"iPhone_Moment" position:0.75 selector:@selector(openAppStoreMoment)];
		}
	}

	return backgroundView;
}

- (void)settingsButtonAction:(UIButton *)button {
	if (![[A3AppDelegate instance] launchAppNamed:A3AppName_Settings verifyPasscode:YES animated:YES]) {
		self.selectedAppName = A3AppName_Settings;
	}
}

- (void)helpButtonAction:(id)sender {
}

- (void)addAppLinkButtonToView:(UIView *)targetView title:(NSString *)title imageName:(NSString *)imageName position:(CGFloat)position selector:(SEL)selector {
	CGRect screenBounds = [A3UIDevice screenBoundsAdjustedWithOrientation];
	
	UILabel *appTitle = [UILabel new];
	appTitle.textColor = [UIColor whiteColor];
	CGFloat fontSize;
	if (IS_IPAD_PRO) {
		fontSize = 17;
	} else {
		fontSize = IS_IPHONE ? 11 : 13;
	}
	appTitle.font = [UIFont systemFontOfSize:fontSize];
	appTitle.text = title;
	appTitle.textAlignment = NSTextAlignmentCenter;
	[targetView addSubview:appTitle];

	[appTitle makeConstraints:^(MASConstraintMaker *make) {
		make.centerX.equalTo(targetView.right).with.multipliedBy(position);
		CGFloat offset;
		if (IS_IPAD_PRO) {
			offset = -18;
		} else {
			offset = screenBounds.size.height == 480 ? -5 : -15;
		}
		make.bottom.equalTo(targetView.bottom).with.offset(offset);
	}];

	UIButton *appButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[appButton setBackgroundImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
	[targetView addSubview:appButton];

	[appButton makeConstraints:^(MASConstraintMaker *make) {
		make.centerX.equalTo(targetView.right).with.multipliedBy(position);
		make.bottom.equalTo(appTitle.top).with.offset(-4);
		if (IS_IPAD_PRO) {
			make.width.equalTo(@80);
			make.height.equalTo(@80);
		}
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

@end

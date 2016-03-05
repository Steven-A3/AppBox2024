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
	[super viewWillAppear:animated];

	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
	
	UINavigationController *navigationController = self.navigationController;
	[navigationController setNavigationBarHidden:YES animated:NO];

	UIImage *image = [UIImage new];
	[navigationController.navigationBar setBackgroundImage:image forBarMetrics:UIBarMetricsDefault];
	[navigationController.navigationBar setShadowImage:image];
}

- (NSDictionary *)groupColors {
	if (!_groupColors) {
		_groupColors = @{
				A3AppGroupNameCalculator:self.calculatorColor,
				A3AppGroupNameProductivity:self.productivityColor,
				A3AppGroupNameConverter:self.converterColor,
				A3AppGroupNameUtility:self.utilityColor,
				A3AppGroupNameReference:self.referenceColor,
				A3AppGroupNameNone:self.noneColor,
		};
	}
	return _groupColors;
}

- (UIColor *)utilityColor {
	// 253	148	38
	return [UIColor colorWithRed:253.0/255.0 green:148.0/255.0 blue:38.0/255.0 alpha:1.0];
}

- (UIColor *)calculatorColor {
	// 21	126	251
	return [UIColor colorWithRed:21.0/255.0 green:126.0/255.0 blue:251.0/255.0 alpha:1.0];
}

- (UIColor *)referenceColor {
	// 252	49	89
	return [UIColor colorWithRed:252.0/255.0 green:49.0/255.0 blue:89.0/255.0 alpha:1.0];
}

- (UIColor *)converterColor {
	// 89	90	211
	return [UIColor colorWithRed:89.0/255.0 green:90.0/255.0 blue:211.0/255.0 alpha:1.0];
}

- (UIColor *)productivityColor {
	// 104	216	69
	return [UIColor colorWithRed:104.0/255.0 green:216.0/255.0 blue:69.0/255.0 alpha:1.0];
}

- (UIColor *)noneColor {
	// 116	124	127
	return [UIColor colorWithRed:116.0/255.0 green:124.0/255.0 blue:127.0/255.0 alpha:1.0];
}

- (NSMutableDictionary *)imageNameDictionary {
	if (!_imageNameDictionary) {
		A3AppDelegate *appDelegate = [A3AppDelegate instance];
		NSArray<NSDictionary *> *allMenu = [appDelegate allMenu];

		_imageNameDictionary = [NSMutableDictionary new];
		for (NSDictionary *group in allMenu) {
			for (NSDictionary *menuInfo in group[kA3AppsExpandableChildren]) {
				_imageNameDictionary[menuInfo[kA3AppsMenuName]] = menuInfo[kA3AppsMenuImageName];
			}
		}
	}
	return _imageNameDictionary;
}

- (UIView *)backgroundView {
	UIView *backgroundView = [UIView new];
	backgroundView.backgroundColor = [UIColor colorWithRed:42.0/255.0 green:54.0/255.0 blue:59.0/255.0 alpha:1.0];

	UIButton *helpButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[helpButton setBackgroundImage:[[UIImage imageNamed:@"help"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
	helpButton.tintColor = [UIColor whiteColor];

	[backgroundView addSubview:helpButton];

	UIView *superview = backgroundView;
	[helpButton mas_makeConstraints:^(MASConstraintMaker *make) {
		make.left.equalTo(superview.left).with.offset(15);
		make.top.equalTo(superview.top).with.offset(30);
		make.width.equalTo(@35);
		make.height.equalTo(@35);
	}];

	UIButton *settingsButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[settingsButton setBackgroundImage:[[UIImage imageNamed:@"general"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
	settingsButton.tintColor = [UIColor whiteColor];
	[backgroundView addSubview:settingsButton];

	[settingsButton makeConstraints:^(MASConstraintMaker *make) {
		make.top.equalTo(superview.top).with.offset(30);
		make.right.equalTo(superview.right).with.offset(-15);
		make.width.equalTo(@35);
		make.height.equalTo(@35);
	}];

	UILabel *titleLabel = [UILabel new];
	titleLabel.text = @"AppBox Pro®";
	titleLabel.textColor = [UIColor whiteColor];
	titleLabel.font = [UIFont systemFontOfSize:26];
	titleLabel.textAlignment = NSTextAlignmentCenter;
	[backgroundView addSubview:titleLabel];

	[titleLabel makeConstraints:^(MASConstraintMaker *make) {
		make.centerX.equalTo(superview.centerX);
		make.top.equalTo(superview.top).with.offset(32);
	}];

	[self addAppLinkButtonToView:backgroundView
						   title:@"AppBox"
					   imageName:@"iPad_AppBox"
						position:0.3];

	[self addAppLinkButtonToView:backgroundView
						   title:@"Numpad"
					   imageName:@"iPad_Numpad"
						position:0.5];

	[self addAppLinkButtonToView:backgroundView
						   title:@"Moment"
					   imageName:@"iPad_Moment"
						position:0.7];

	return backgroundView;
}

- (void)addAppLinkButtonToView:(UIView *)targetView title:(NSString *)title imageName:(NSString *)imageName position:(CGFloat)position {
	UILabel *appTitle = [UILabel new];
	appTitle.textColor = [UIColor whiteColor];
	appTitle.font = [UIFont systemFontOfSize:11];
	appTitle.text = title;
	appTitle.textAlignment = NSTextAlignmentCenter;
	[targetView addSubview:appTitle];

	[appTitle makeConstraints:^(MASConstraintMaker *make) {
		make.centerX.equalTo(targetView.right).with.multipliedBy(position);
		make.bottom.equalTo(targetView.bottom).with.offset(-15);
	}];

	UIButton *appButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[appButton setBackgroundImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
	[targetView addSubview:appButton];

	[appButton makeConstraints:^(MASConstraintMaker *make) {
		make.centerX.equalTo(targetView.right).with.multipliedBy(position);
		make.bottom.equalTo(appTitle.top).with.offset(-10);
	}];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
	[self setNeedsStatusBarAppearanceUpdate];
	return UIStatusBarStyleLightContent;
}

@end

//
//  UIViewController(A3AppCategory)
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 4/18/13 8:46 PM.
//  Copyright (c) 2012 ALLABOUTAPPS. All rights reserved.
//

#import <objc/runtime.h>
#import "UIViewController+A3AppCategory.h"
#import "A3UIDevice.h"
#import "A3ActionMenuViewController_iPad.h"
#import "A3ActionMenuViewController_iPhone.h"
#import "UIView+Screenshot.h"
#import "A3NumberKeyboardViewController.h"
#import "A3FrequencyKeyboardViewController.h"
#import "A3DateKeyboardViewController.h"
#import "A3NumberKeyboardViewController_iPad.h"
#import "A3NumberKeyboardViewController_iPhone.h"
#import "common.h"

static char const *const key_actionMenuViewController 			= "key_actionMenuViewController";
static char const *const key_numberKeyboardViewController 		= "key_numberKeyboardViewController";
static char const *const key_frequencyKeyboardViewController 	= "key_frequencyKeyboardViewController";
static char const *const key_dateKeyboardViewController 		= "key_dateKeyboardViewController";
static char const *const key_currencyFormatter					= "key_currencyFormatter";
static char const *const key_decimalFormatter 					= "key_decimalFormatter";
static char const *const key_percentFormatter					= "key_percentFormatter";
static char const *const key_actionMenuAnimating				= "key_actionMenuAnimating";

@implementation UIViewController (A3AppCategory)

#define A3_ACTION_MENU_COVER_VIEW_TAG		79325

- (UIViewController *)actionMenuViewController {
	UIViewController *viewController = objc_getAssociatedObject(self, key_actionMenuViewController);

	if (nil != viewController) return viewController;

	if (DEVICE_IPAD) {
		A3ActionMenuViewController_iPad *iPadViewController = [[A3ActionMenuViewController_iPad alloc] initWithNibName:@"A3ActionMenuViewController_iPad" bundle:nil];
		viewController = iPadViewController;
	} else {
		A3ActionMenuViewController_iPhone *iPhoneViewController = [[A3ActionMenuViewController_iPhone alloc] initWithNibName:@"A3ActionMenuViewController_iPhone" bundle:nil];
		viewController = iPhoneViewController;
	}
	objc_setAssociatedObject(self, key_actionMenuViewController, viewController, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
	return viewController;
}

- (void)setActionMenuViewController:(UIViewController *)viewController {
	objc_setAssociatedObject(self, key_actionMenuViewController, viewController, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)presentActionMenuWithDelegate:(id<A3ActionMenuViewControllerDelegate>) delegate {
	if (self.actionMenuAnimating) return;

	{
		UIView *coverView = [self.navigationController.view viewWithTag:A3_ACTION_MENU_COVER_VIEW_TAG];
		if (nil != coverView) {
			[self closeActionMenuViewWithAnimation:YES];
			return;
		}
	}

	CGRect frame = self.actionMenuViewController.view.frame;
	frame.origin.y = 34.0;
	self.actionMenuViewController.view.frame = frame;

	if (DEVICE_IPAD) {
		((A3ActionMenuViewController_iPad *) self.actionMenuViewController).delegate = delegate;
	} else {
		((A3ActionMenuViewController_iPhone *) self.actionMenuViewController).delegate = delegate;
	}
	[self.navigationController.view insertSubview:[self.actionMenuViewController view] belowSubview:self.view];

	UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureOnCoverView:)];
	UIImage *image = [self.view screenshotWithOptimization:NO];
	UIImageView *coverView = [[UIImageView alloc] initWithImage:image];
	coverView.tag = A3_ACTION_MENU_COVER_VIEW_TAG;
	coverView.frame = CGRectOffset(self.view.bounds, 0.0, 44.0);
	coverView.userInteractionEnabled = YES;
	coverView.backgroundColor = [UIColor clearColor];
	[coverView addGestureRecognizer:tapGestureRecognizer];
	[self.navigationController.view addSubview:coverView];

	[UIView animateWithDuration:0.3 animations:^{
		coverView.frame = CGRectOffset(coverView.frame, 0.0, 50.0);
		self.actionMenuAnimating = YES;
	} completion:^(BOOL finished){
		self.actionMenuAnimating = NO;
	}];
}

- (void)tapGestureOnCoverView:(id)sender {
	[self closeActionMenuViewWithAnimation:YES];
}

- (void)closeActionMenuViewWithAnimation:(BOOL)animate {
	if (self.actionMenuAnimating) return;

	UIView *coverView = [self.navigationController.view viewWithTag:A3_ACTION_MENU_COVER_VIEW_TAG];
	if (nil == coverView) return;

	if (animate) {
		[UIView animateWithDuration:0.3 animations:^{
			coverView.frame = CGRectOffset(coverView.frame, 0.0, -50.0);
			self.actionMenuAnimating = YES;
		} completion:^(BOOL finished){
			[coverView removeFromSuperview];
			[[[self.navigationController.view subviews] lastObject] removeFromSuperview];	// remove menu view
			self.actionMenuAnimating = NO;
		}];
	} else {
		[coverView removeFromSuperview];
		[[[self.navigationController.view subviews] lastObject] removeFromSuperview];	// remove menu view
	}
}

- (void)addToolsButtonWithAction:(SEL)action {
	NSString *imagePath = [[NSBundle mainBundle] pathForResource:@"tools" ofType:@"png"];
	UIImage *image = [[UIImage alloc] initWithContentsOfFile:imagePath];
	UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
	[button setImage:image forState:UIControlStateNormal];
	[button addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
	button.bounds = CGRectMake(0.0, 0.0, 42.0, 32.0);
	UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];

	self.navigationItem.rightBarButtonItem = barButtonItem;
}

- (A3NumberKeyboardViewController *)numberKeyboardViewController {
	A3NumberKeyboardViewController *viewController = objc_getAssociatedObject(self, key_numberKeyboardViewController);
	if (nil == viewController) {
		if (DEVICE_IPAD) {
			viewController = [[A3NumberKeyboardViewController_iPad alloc] initWithNibName:@"A3NumberKeyboardViewController_iPad" bundle:nil];
			viewController.delegate = self;
		} else {
			viewController = [[A3NumberKeyboardViewController_iPhone alloc] initWithNibName:@"A3NumberKeyboardViewController_iPhone" bundle:nil];
			viewController.delegate = self;
		}
		objc_setAssociatedObject(self, key_numberKeyboardViewController, viewController, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
	}
	return viewController;
}

- (void)setNumberKeyboardViewController:(A3NumberKeyboardViewController *)keyboardViewController {
	objc_setAssociatedObject(self, key_numberKeyboardViewController, keyboardViewController, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (A3FrequencyKeyboardViewController *)frequencyKeyboardViewController {
	A3FrequencyKeyboardViewController *viewController = objc_getAssociatedObject(self, key_frequencyKeyboardViewController);
	if (nil == viewController) {
		viewController = [[A3FrequencyKeyboardViewController alloc] initWithNibName:@"A3FrequencyKeyboardViewController" bundle:nil];
		viewController.delegate = (id <A3FrequencyKeyboardDelegate>) self;
		objc_setAssociatedObject(self, key_frequencyKeyboardViewController, viewController, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
	}
	return viewController;
}

- (void)setFrequencyKeyboardViewController:(A3FrequencyKeyboardViewController *)frequencyKeyboardViewController1 {
	objc_setAssociatedObject(self, key_frequencyKeyboardViewController, frequencyKeyboardViewController1, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (A3DateKeyboardViewController *)dateKeyboardViewController {
	A3DateKeyboardViewController *viewController = objc_getAssociatedObject(self, key_dateKeyboardViewController);
	if (nil == viewController) {
		viewController = [[A3DateKeyboardViewController alloc] initWithNibName:@"A3DateKeyboardViewController" bundle:nil];
		viewController.delegate = (id <A3DateKeyboardDelegate>) self;
		viewController.workingMode = A3DateKeyboardWorkingModeYearMonthDay;
		objc_setAssociatedObject(self, key_dateKeyboardViewController, viewController, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
	}
	return viewController;
}

- (void)setDateKeyboardViewController:(A3DateKeyboardViewController *)dateKeyboardViewController1 {
	objc_setAssociatedObject(self, key_dateKeyboardViewController, dateKeyboardViewController1, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSNumberFormatter *)currencyFormatter {
	NSNumberFormatter *formatter = objc_getAssociatedObject(self, key_currencyFormatter);
	if (nil == formatter) {
		formatter = [[NSNumberFormatter alloc] init];
		[formatter setNumberStyle:NSNumberFormatterCurrencyStyle];
		objc_setAssociatedObject(self, key_currencyFormatter, formatter, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
	}
	return formatter;
}

- (void)setCurrencyFormatter:(NSNumberFormatter *)currencyFormatter {
	objc_setAssociatedObject(self, key_currencyFormatter, currencyFormatter, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSNumberFormatter *)decimalFormatter {
	NSNumberFormatter *formatter = objc_getAssociatedObject(self, key_decimalFormatter);
	if (nil == formatter) {
		formatter = [[NSNumberFormatter alloc] init];
		[formatter setNumberStyle:NSNumberFormatterDecimalStyle];
		objc_setAssociatedObject(self, key_decimalFormatter, formatter, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
	}
	return formatter;
}

- (void)setDecimalFormatter:(NSNumberFormatter *)decimalFormatter {
	objc_setAssociatedObject(self, key_decimalFormatter, decimalFormatter, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSNumberFormatter *)percentFormatter {
	NSNumberFormatter *formatter = objc_getAssociatedObject(self, key_percentFormatter);
	if (nil == formatter) {
		formatter = [[NSNumberFormatter alloc] init];
		[formatter setNumberStyle:NSNumberFormatterPercentStyle];
		objc_setAssociatedObject(self, key_percentFormatter, formatter, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
	}
	return formatter;
}

- (void)setPercentFormatter:(NSNumberFormatter *)percentFormatter {
	objc_setAssociatedObject(self, key_percentFormatter, percentFormatter, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSString *)zeroCurrency {
	return [self.currencyFormatter stringFromNumber:[NSDecimalNumber zero]];
}

- (void)drawLinearGradientToContext:(CGContextRef)context rect:(CGRect)rect withColors:(NSArray *) colors {
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	CGFloat locations[] = { 0.0f, 1.0f };

	CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef) colors, locations);

	CGPoint startPoint = CGPointMake(CGRectGetMidX(rect), CGRectGetMinY(rect));
	CGPoint endPoint = CGPointMake(CGRectGetMidX(rect), CGRectGetMaxY(rect));

	CGContextSaveGState(context);
	CGContextAddRect(context, rect);
	CGContextClip(context);
	CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, 0);
	CGContextRestoreGState(context);

	CGGradientRelease(gradient);
}

- (UIImage *)navigationBarBackgroundImageForBarMetrics:(UIBarMetrics)barMetrics {
	CGRect screenBounds = [UIScreen mainScreen].bounds;
	CGSize imageSize = CGSizeMake(barMetrics == UIBarMetricsDefault ? CGRectGetWidth(screenBounds) : CGRectGetHeight(screenBounds), 44.0f);
	UIGraphicsBeginImageContextWithOptions(imageSize, YES, 2.0f);

	CGContextRef context = UIGraphicsGetCurrentContext();
	CGRect rect = CGRectMake(0.0f, 0.0f, imageSize.width, imageSize.height);

	CGContextSetRGBStrokeColor(context, 66.0f/255.0f, 66.0f/255.0f, 67.0f/255.0f, 1.0f);
	CGContextAddRect(context, rect);
	CGContextStrokePath(context);

	CGContextSetRGBFillColor(context, 0.0f, 0.0f, 0.0f, 0.8f);
	CGContextAddRect(context, rect);
	CGContextFillPath(context);

	NSArray *colors = @[
			(__bridge id)[UIColor colorWithRed:48.0f/255.0f green:48.0f/255.0f blue:48.0f/255.0f alpha:1.0f].CGColor,
			(__bridge id)[UIColor colorWithRed:24.0f/255.0f green:25.0f/255.0f blue:27.0f/255.0f alpha:0.0f].CGColor,
	];

	[self drawLinearGradientToContext:context rect:CGRectMake(CGRectGetMinX(rect), CGRectGetMinY(rect), CGRectGetWidth(rect), 8.0f) withColors:colors];

	UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();

	return image;
}

- (void)setBlackBackgroundImageForNavigationBar {
	[self.navigationController.navigationBar setBackgroundImage:[self navigationBarBackgroundImageForBarMetrics:UIBarMetricsDefault] forBarMetrics:UIBarMetricsDefault];
	[self.navigationController.navigationBar setBackgroundImage:[self navigationBarBackgroundImageForBarMetrics:UIBarMetricsLandscapePhone] forBarMetrics:UIBarMetricsLandscapePhone];
}

- (UIImage *)navigationBarSilverBackgroundImageForBarMetrics:(UIBarMetrics)barMetrics {
	CGRect screenBounds = [UIScreen mainScreen].bounds;
	CGSize imageSize = CGSizeMake(barMetrics == UIBarMetricsDefault ? CGRectGetWidth(screenBounds) : CGRectGetHeight(screenBounds), 44.0);
	UIGraphicsBeginImageContextWithOptions(imageSize, YES, 2.0f);

	CGContextRef context = UIGraphicsGetCurrentContext();
	CGRect rect = CGRectMake(0.0f, 0.0f, imageSize.width, imageSize.height);

	NSArray *colors = @[
			(__bridge id)[UIColor colorWithRed:248.0f/255.0f green:245.0f/255.0f blue:245.0f/255.0f alpha:1.0f].CGColor,
			(__bridge id)[UIColor colorWithRed:198.0f/255.0f green:199.0f/255.0f blue:199.0f/255.0f alpha:1.0f].CGColor,
	];

	[self drawLinearGradientToContext:context rect:rect withColors:colors];

	CGContextSetFillColorWithColor(context, [[UIColor colorWithRed:171.0/255.0 green:171.0/255.0 blue:171.0/255.0 alpha:1.0] CGColor]);
	CGContextFillRect(context, CGRectMake(CGRectGetMinX(rect), CGRectGetMaxY(rect) - 1.0, CGRectGetWidth(rect), 1.0));

	UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();

	return image;
}

- (void)setSilverBackgroundImageForNavigationBar {
	[self.navigationController.navigationBar setTitleTextAttributes:@{UITextAttributeTextColor:[UIColor colorWithRed:71.0/255.0 green:71.0/255.0 blue:71.0/255.0 alpha:1.0]}];
	[self.navigationController.navigationBar setBackgroundImage:[self navigationBarSilverBackgroundImageForBarMetrics:UIBarMetricsDefault] forBarMetrics:UIBarMetricsDefault];
	[self.navigationController.navigationBar setBackgroundImage:[self navigationBarSilverBackgroundImageForBarMetrics:UIBarMetricsLandscapePhone] forBarMetrics:UIBarMetricsLandscapePhone];
}

- (CAGradientLayer *)addTopGradientLayerToView:(UIView *)view {
	CAGradientLayer *gradientLayer = [CAGradientLayer layer];
	gradientLayer.anchorPoint = CGPointMake(0.0, 0.0);
	gradientLayer.position = CGPointMake(0.0, 1.0);
	gradientLayer.startPoint = CGPointMake(0.5, 0.0);
	gradientLayer.endPoint = CGPointMake(0.5, 1.0);
	gradientLayer.bounds = CGRectMake(0.0, 0.0, view.bounds.size.width, 8.0);
	gradientLayer.colors = @[(id)[UIColor colorWithWhite:0.0 alpha:0.3].CGColor, (id)[UIColor colorWithWhite:0.0 alpha:0.0].CGColor];
	[view.layer addSublayer:gradientLayer];

	return gradientLayer;
}

- (NSString *)currencyFormattedString:(NSString *)source {
	if ([source floatValue] == 0.0) return @"";
	return [self.currencyFormatter stringFromNumber:[NSNumber numberWithFloat:[source floatValue]]];
}

- (NSString *)percentFormattedString:(NSString *)source {
	if ([source floatValue] == 0.0) return @"";
	return [self.percentFormatter stringFromNumber:[NSNumber numberWithFloat:[source floatValue] / 100.0]];
}

- (void)setActionMenuAnimating:(BOOL)animating {
	objc_setAssociatedObject(self, key_actionMenuAnimating, [NSNumber numberWithBool:animating], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)actionMenuAnimating {
	NSNumber *number = objc_getAssociatedObject(self, key_actionMenuAnimating);
	return number.boolValue;
}

- (void)alertCheck {
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Check" message:@"Nice!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[alertView show];
}

@end
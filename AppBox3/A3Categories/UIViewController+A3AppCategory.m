//
//  UIViewController(A3AppCategory)
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 4/18/13 8:46 PM.
//  Copyright (c) 2012 ALLABOUTAPPS. All rights reserved.
//

#import "A3CurrencyViewController.h"
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
#import "A3BarButton.h"
#import "A3BlackBarButton.h"
#import "A3EmptyActionMenuViewController_iPad.h"
#import "A3FrequencyKeyboardViewController_iPhone.h"
#import "A3DateKeyboardViewController_iPad.h"
#import "A3DateKeyboardViewController_iPhone.h"
#import "CommonUIDefinitions.h"
#import "common.h"
#import "UIViewController+MMDrawerController.h"
#import "A3RootViewController.h"
#import "A3AppDelegate.h"
#import "A3NumberKeyboardSimpleVC_iPad.h"

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

- (A3RootViewController *)A3RootViewController {
	return [[A3AppDelegate instance] rootViewController];
}

- (UIViewController *)actionMenuViewController {
	UIViewController *viewController = objc_getAssociatedObject(self, key_actionMenuViewController);

	if (nil != viewController) return viewController;

	if (IS_IPAD) {
		A3ActionMenuViewController_iPad *iPadViewController = [[A3ActionMenuViewController_iPad alloc] initWithNibName:@"A3ActionMenuViewController_iPad" bundle:nil];
		viewController = iPadViewController;
	} else {
		A3ActionMenuViewController_iPhone *iPhoneViewController = [[A3ActionMenuViewController_iPhone alloc] initWithNibName:@"A3ActionMenuViewController_iPhone" bundle:nil];
		viewController = iPhoneViewController;
	}
	objc_setAssociatedObject(self, key_actionMenuViewController, viewController, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
	return viewController;
}

- (UIViewController *)emptyActionMenuViewController {
	UIViewController *viewController = objc_getAssociatedObject(self, key_actionMenuViewController);

	if (nil != viewController) return viewController;

	A3EmptyActionMenuViewController_iPad *iPadViewController = [[A3EmptyActionMenuViewController_iPad alloc] initWithNibName:@"A3EmptyActionMenuViewController_iPad" bundle:nil];
	viewController = iPadViewController;
	objc_setAssociatedObject(self, key_actionMenuViewController, viewController, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
	return viewController;
}

- (void)setActionMenuViewController:(UIViewController *)viewController {
	objc_setAssociatedObject(self, key_actionMenuViewController, viewController, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)removeCoverView {
	UIView *coverView = [self.navigationController.view viewWithTag:A3_ACTION_MENU_COVER_VIEW_TAG];
	if (nil != coverView) {
		[self closeActionMenuViewWithAnimation:YES];
		return YES;
	}
	return NO;
}

- (void)presentActionMenuWithDelegate:(id<A3ActionMenuViewControllerDelegate>) delegate {
	if (self.actionMenuAnimating || [self removeCoverView]) return;

	CGRect frame = self.actionMenuViewController.view.frame;
	frame.origin.y = 34.0;
	self.actionMenuViewController.view.frame = frame;

	if (IS_IPAD) {
		((A3ActionMenuViewController_iPad *) self.actionMenuViewController).delegate = delegate;
	} else {
		((A3ActionMenuViewController_iPhone *) self.actionMenuViewController).delegate = delegate;
	}
	[self.navigationController.view insertSubview:[self.actionMenuViewController view] belowSubview:self.view];

	[self coverAndAnimateActionMenuView:self.actionMenuViewController.view];
}

- (void)presentEmptyActionMenu {
	if (self.actionMenuAnimating || [self removeCoverView]) return;

	CGRect frame = self.emptyActionMenuViewController.view.frame;
	if (!IS_IPAD) {
		frame.size.width = APP_VIEW_WIDTH_iPHONE;
	}
	frame.origin.y = 34.0;
	self.emptyActionMenuViewController.view.frame = frame;

	[self coverAndAnimateActionMenuView:self.emptyActionMenuViewController.view];
}

- (void)coverAndAnimateActionMenuView:(UIView *)actionMenuView {
	[self.navigationController.view insertSubview:actionMenuView belowSubview:self.view];

	UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureOnCoverView:)];

	UIImageView *coverView = [[UIImageView alloc] init];
	coverView.image = [self.view imageByRenderingView];
	coverView.tag = A3_ACTION_MENU_COVER_VIEW_TAG;
	coverView.frame = CGRectOffset(self.view.bounds, 0.0, 44.0);
	coverView.userInteractionEnabled = YES;
	[coverView addGestureRecognizer:tapGestureRecognizer];
	[self.navigationController.view addSubview:coverView];

	[UIView animateWithDuration:0.3 animations:^{
		coverView.frame = CGRectOffset(coverView.frame, 0.0, 50.0);
		self.actionMenuAnimating = YES;
	} completion:^(BOOL finished){
		self.actionMenuAnimating = NO;
	}];

	return;
}

- (void)tapGestureOnCoverView:(id)sender {
	[self closeActionMenuViewWithAnimation:YES];
}

- (void)closeActionMenuViewWithAnimation:(BOOL)animate {
	if (self.actionMenuAnimating) return;

	UIView *coverView = [self.navigationController.view viewWithTag:A3_ACTION_MENU_COVER_VIEW_TAG];

	if (animate) {
		[UIView animateWithDuration:0.3 animations:^{
			coverView.frame = CGRectOffset(coverView.frame, 0.0, -50.0);
			self.actionMenuAnimating = YES;
		} completion:^(BOOL finished){
			[coverView removeFromSuperview];
			[self.actionMenuViewController.view removeFromSuperview];
			self.actionMenuAnimating = NO;
			[self setActionMenuViewController:nil];
		}];
	} else {
		[coverView removeFromSuperview];
		[self.actionMenuViewController.view removeFromSuperview];
		[self setActionMenuViewController:nil];
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

- (A3NumberKeyboardViewController *)iPadNumberKeyboard {
	return [[A3NumberKeyboardViewController_iPad alloc] initWithNibName:@"A3NumberKeyboardViewController_iPad" bundle:nil];
}

- (A3NumberKeyboardViewController *)simpleNumberKeyboard {
	A3NumberKeyboardViewController *viewController;
	if (IS_IPHONE) {
		viewController = [[A3NumberKeyboardViewController_iPhone alloc] initWithNibName:@"A3NumberKeyboardSimpleVC_iPhone" bundle:nil];
	} else {
		viewController = [[A3NumberKeyboardSimpleVC_iPad alloc] initWithNibName:@"A3NumberKeyboardSimpleVC_iPad" bundle:nil];
	}
	return viewController;
}

- (A3NumberKeyboardViewController *)normalNumberKeyboard {
	A3NumberKeyboardViewController *viewController;
	if (IS_IPAD) {
		viewController = [self iPadNumberKeyboard];
		viewController.delegate = self;
	} else {
		viewController = [[A3NumberKeyboardViewController_iPhone alloc] initWithNibName:@"A3NumberKeyboardViewController_iPhone" bundle:nil];
		viewController.delegate = self;
	}
	return viewController;
}

- (A3NumberKeyboardViewController *)numberKeyboardViewController {
	A3NumberKeyboardViewController *viewController = objc_getAssociatedObject(self, key_numberKeyboardViewController);
	if (nil == viewController) {
		viewController = [self normalNumberKeyboard];
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
		if (IS_IPAD) {
			viewController = [[A3FrequencyKeyboardViewController alloc] initWithNibName:@"A3FrequencyKeyboardViewController_iPad" bundle:nil];
		} else {
			viewController = [[A3FrequencyKeyboardViewController_iPhone alloc] initWithNibName:@"A3FrequencyKeyboardViewController_iPhone" bundle:nil];
		}
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
		if (IS_IPAD) {
			viewController = [[A3DateKeyboardViewController_iPad alloc] initWithNibName:@"A3DateKeyboardViewController_iPad" bundle:nil];
		} else {
			viewController = [[A3DateKeyboardViewController_iPhone alloc] initWithNibName:@"A3DateKeyboardViewController_iPhone" bundle:nil];
		}
		viewController.delegate = (id <A3DateKeyboardDelegate>) self;
		viewController.workingMode = A3DateKeyboardWorkingModeYearMonthDay;
		objc_setAssociatedObject(self, key_dateKeyboardViewController, viewController, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
	}
	return viewController;
}

- (void)setDateKeyboardViewController:(A3DateKeyboardViewController *)dateKeyboardViewController1 {
	objc_setAssociatedObject(self, key_dateKeyboardViewController, dateKeyboardViewController1, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSString *)defaultCurrencyCode {
    return nil;
}

- (NSNumberFormatter *)currencyFormatter {
	NSNumberFormatter *formatter = objc_getAssociatedObject(self, key_currencyFormatter);
	if (nil == formatter) {
		formatter = [[NSNumberFormatter alloc] init];
		NSString *userCurrencyCode = nil;
		if ([self respondsToSelector:@selector(defaultCurrencyCode)]) {
			userCurrencyCode = [self performSelector:@selector(defaultCurrencyCode)];
			if ([userCurrencyCode length]) {
				[formatter setCurrencyCode:userCurrencyCode];
			}
		}

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
	return [self.currencyFormatter stringFromNumber: @0 ];
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

- (CAGradientLayer *)addTopGradientLayerToView:(UIView *)view position:(CGFloat)position {
	CAGradientLayer *gradientLayer = [CAGradientLayer layer];
	gradientLayer.anchorPoint = CGPointMake(0.0, 0.0);
	gradientLayer.position = CGPointMake(0.0, position);
	gradientLayer.startPoint = CGPointMake(0.5, 0.0);
	gradientLayer.endPoint = CGPointMake(0.5, 1.0);
	gradientLayer.bounds = CGRectMake(0.0, 0.0, view.bounds.size.width, 8.0);
	gradientLayer.colors = @[(id)[UIColor colorWithWhite:0.0 alpha:0.3].CGColor, (id)[UIColor colorWithWhite:0.0 alpha:0.0].CGColor];
	[view.layer addSublayer:gradientLayer];

	return gradientLayer;
}

- (CAGradientLayer *)addTopGradientLayerToWhiteView:(UIView *)view position:(CGFloat)position {
	CAGradientLayer *gradientLayer = [CAGradientLayer layer];
	gradientLayer.anchorPoint = CGPointMake(0.0, 0.0);
	gradientLayer.position = CGPointMake(0.0, position);
	gradientLayer.startPoint = CGPointMake(0.5, 0.0);
	gradientLayer.endPoint = CGPointMake(0.5, 1.0);
	gradientLayer.bounds = CGRectMake(0.0, 0.0, view.bounds.size.width, 8.0);
	gradientLayer.colors = @[(id)[UIColor colorWithRed:189.0/255.0 green:190.0/255.0 blue:191.0/255.0 alpha:1.0].CGColor,
			(id)[UIColor colorWithRed:236.0/255.0 green:237.0/255.0 blue:238.0/255.0 alpha:1.0].CGColor];
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

- (UIBarButtonItem *)barButtonItemWithTitle:(NSString *)title action:(SEL)selector {
	A3BarButton *aButton = [[A3BarButton alloc] initWithFrame:CGRectZero];
	aButton.bounds = CGRectMake(0.0, 0.0, 52.0, 30.0);
	[aButton setTitle:title forState:UIControlStateNormal];
	[aButton addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];

	return [[UIBarButtonItem alloc] initWithCustomView:aButton];
}

- (UIBarButtonItem *)blackBarButtonItemWithTitle:(NSString *)title action:(SEL)selector {
	A3BlackBarButton *aButton = [[A3BlackBarButton alloc] initWithFrame:CGRectZero];
	aButton.bounds = CGRectMake(0.0, 0.0, 52.0, 30.0);
	[aButton setTitle:title forState:UIControlStateNormal];
	[aButton addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];

	return [[UIBarButtonItem alloc] initWithCustomView:aButton];
}

- (void)addActionIcon:(NSString *)iconName title:(NSString *)title selector:(SEL)selector atIndex:(NSInteger)index {
	static NSArray *coordinateX;
	CGFloat labelWidth, labelHeight;
	if (IS_IPAD) {
		coordinateX = @[@156.0, @340.0, @523.0];
		labelWidth = 130.0;
		labelHeight = 32.0;
	} else {
		coordinateX = @[@20.0, @120.0, @225.0];
		labelWidth = 65.0;
		labelHeight = 30.0;
	}

	UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
	UIImage *buttonImage = [UIImage imageNamed:iconName];

	[button setImage:buttonImage forState:UIControlStateNormal];
	[button addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
    NSString *coordinateXStr = coordinateX[index];
	button.frame = CGRectMake([coordinateXStr floatValue], 18.0, buttonImage.size.width, buttonImage.size.height);
	[self.actionMenuViewController.view addSubview:button];

	CGRect frame = CGRectMake([coordinateXStr floatValue] + buttonImage.size.width + 5.0, 19.0, labelWidth, labelHeight);
	UILabel *label = [[UILabel alloc] initWithFrame:frame];
	label.backgroundColor = [UIColor clearColor];
	label.text = title;
	label.font = [UIFont systemFontOfSize:14.5];
	label.textColor = [UIColor whiteColor];
	label.userInteractionEnabled = YES;
	[self.actionMenuViewController.view addSubview:label];

	UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:selector];
	[label addGestureRecognizer:tapGestureRecognizer];
}

- (CGRect)boundsForRightSideView {
	CGRect screenBounds = [[UIScreen mainScreen] bounds];
	CGFloat height = [A3UIDevice deviceOrientationIsPortrait] ? screenBounds.size.height : screenBounds.size.width;
	height -= 44.0 + 20.0;
	CGRect bounds = CGRectMake(0.0, 0.0, 320.0, height);
	return bounds;
}

- (void)leftBarButtonAppsButton {
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Apps" style:UIBarButtonItemStylePlain target:self action:@selector(appsButtonAction)];
}

- (void)appsButtonAction {
	[[self mm_drawerController] toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
}

- (UIBarButtonItem *)appListBarButtonItemWithSelector:(SEL)selector {
	UIBarButtonItem *sideMenuButton = [[UIBarButtonItem alloc] initWithTitle:@"Apps" style:UIBarButtonItemStylePlain target:self action:selector];
	return sideMenuButton;
}

- (void)addTwoButtons:(NSArray *)buttons toView:(UIView *)view {
	NSAssert([buttons count] == 2, @"The number of buttons must 2 but it is %d", [buttons count]);
	UIButton *button1 = buttons[0];
	UIButton *button2 = buttons[1];
	for (UIButton *button in buttons) {
		[view addSubview:button];
		[button setTranslatesAutoresizingMaskIntoConstraints:NO];
	}
	[view addConstraint:[NSLayoutConstraint constraintWithItem:button1
													 attribute:NSLayoutAttributeBottom
													 relatedBy:NSLayoutRelationEqual
														toItem:view
													 attribute:NSLayoutAttributeBottom multiplier:1.0 constant:-10.0]];
	[view addConstraint:[NSLayoutConstraint constraintWithItem:button2
													 attribute:NSLayoutAttributeBottom
													 relatedBy:NSLayoutRelationEqual
														toItem:view
													 attribute:NSLayoutAttributeBottom multiplier:1.0 constant:-10.0]];
	[view addConstraint:[NSLayoutConstraint constraintWithItem:button1
													 attribute:NSLayoutAttributeCenterX
													 relatedBy:NSLayoutRelationEqual
														toItem:view
													 attribute:NSLayoutAttributeCenterX multiplier:2.0 * 1.0 / 3.0 constant:0.0]];
	[view addConstraint:[NSLayoutConstraint constraintWithItem:button2
													 attribute:NSLayoutAttributeCenterX
													 relatedBy:NSLayoutRelationEqual
														toItem:view
													 attribute:NSLayoutAttributeCenterX multiplier:2.0 * 2.0 / 3.0 constant:0.0]];
}

- (void)addThreeButtons:(NSArray *)buttons toView:(UIView *)view {
	NSAssert([buttons count] == 3, @"The number of buttons must 3 but it is %d", [buttons count]);
	UIButton *button1 = buttons[0];
	UIButton *button2 = buttons[1];
	UIButton *button3 = buttons[2];
	for (UIButton *button in buttons) {
		[view addSubview:button];
		[button setTranslatesAutoresizingMaskIntoConstraints:NO];
	}
	NSDictionary *views = NSDictionaryOfVariableBindings(button1, button2, button3);
	[view addConstraint:[NSLayoutConstraint constraintWithItem:button1
													 attribute:NSLayoutAttributeBottom
													 relatedBy:NSLayoutRelationEqual
														toItem:view
													 attribute:NSLayoutAttributeBottom multiplier:1.0 constant:-10.0]];
	[view addConstraint:[NSLayoutConstraint constraintWithItem:button2
													 attribute:NSLayoutAttributeCenterX
													 relatedBy:NSLayoutRelationEqual
														toItem:view
													 attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0]];
	[view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-[button1]-[button2]-[button3]-|" options:NSLayoutFormatAlignAllBaseline metrics:nil views:views]];
}

- (UIView *)moreMenuViewWithButtons:(NSArray *)buttonsArray {
	CGRect frame;
	frame = self.view.frame;
	frame.size.height = 44.0;
	frame.origin.y = -1.0;
	UIView *moreMenuView = [[UIView alloc] initWithFrame:frame];
	moreMenuView.backgroundColor = [UIColor colorWithRed:247.0 / 255.0 green:247.0 / 255.0 blue:247.0 / 255.0 alpha:1.0];
	frame.origin.y += 44.0;
	frame.size.height = 1.0;
	UIView *bottomLineView = [[UIView alloc] initWithFrame:frame];
	bottomLineView.backgroundColor = [UIColor colorWithRed:178.0 / 255.0 green:178.0 / 255.0 blue:178.0 / 255.0 alpha:1.0];
	[moreMenuView addSubview:bottomLineView];

	if ([buttonsArray count] == 2) {
		[self addTwoButtons:buttonsArray toView:moreMenuView];
	} else {
		[self addThreeButtons:buttonsArray toView:moreMenuView];
	}

	return moreMenuView;
}

- (UIView *)presentMoreMenuWithButtons:(NSArray *)buttons tableView:(UITableView *)tableView {
	UIView *moreMenuView = [self moreMenuViewWithButtons:buttons];
	CGRect clippingViewFrame = moreMenuView.frame;
	clippingViewFrame.origin.y = 20.0 + 44.0 - 1.0;
	UIView *clippingView = [[UIView alloc] initWithFrame:clippingViewFrame];
	clippingView.clipsToBounds = YES;
	CGRect frame = clippingView.bounds;
	frame.origin.y -= frame.size.height;
	moreMenuView.frame = frame;
	[clippingView addSubview:moreMenuView];

	[self.navigationController.view insertSubview:clippingView belowSubview:self.view];

	[UIView animateWithDuration:0.3 animations:^{
		CGRect newFrame = moreMenuView.frame;
		newFrame.origin.y = 0.0;
		moreMenuView.frame = newFrame;

		if (tableView) {
			UIEdgeInsets insets = tableView.contentInset;
			insets.top += clippingViewFrame.size.height;
			tableView.contentInset = insets;

			if (tableView.contentOffset.y == -64.0) {
				CGPoint offset = tableView.contentOffset;
				offset.y = -108.0;
				tableView.contentOffset = offset;
			}
		} else {
			newFrame = CGRectOffset(self.view.frame, 0.0, clippingViewFrame.size.height);
			self.view.frame = newFrame;
		}
	}];

	UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(moreMenuDismissAction:)];
	[self.view addGestureRecognizer:gestureRecognizer];

	return clippingView;
}

- (void)dismissMoreMenuView:(UIView *)moreMenuView tableView:(UITableView *)tableView {
	UIView *menuView = moreMenuView.subviews[0];
	[UIView animateWithDuration:0.3 animations:^{
		CGRect frame = menuView.frame;
		frame = CGRectOffset(frame, 0.0, -44.0);
		menuView.frame = frame;

		if (tableView) {
			UIEdgeInsets insets = tableView.contentInset;
			insets.top -= moreMenuView.frame.size.height;
			tableView.contentInset = insets;
		} else {
			frame = CGRectOffset(self.view.frame, 0.0, moreMenuView.frame.size.height);
			self.view.frame = frame;
		}
	} completion:^(BOOL finished) {
		[moreMenuView removeFromSuperview];
	}];
}

- (void)moreMenuDismissAction:(UITapGestureRecognizer *)gestureRecognizer {
	FNLOG(@"You have to override this method to close moreMenuView properly.");
}

- (UIButton *)shareButton {
	UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
	[button setImage:[UIImage imageNamed:@"share"] forState:UIControlStateNormal];
	[button addTarget:self action:@selector(shareButtonAction:) forControlEvents:UIControlEventTouchUpInside];
	return button;
}

- (void)shareButtonAction:(UIButton *)button {

}

- (UIButton *)historyButton {
	UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
	[button setImage:[UIImage imageNamed:@"history"] forState:UIControlStateNormal];
	[button addTarget:self action:@selector(historyButtonAction:) forControlEvents:UIControlEventTouchUpInside];
	return button;
}

- (void)historyButtonAction:(UIButton *)button {

}

- (UIButton *)settingsButton {
	UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
	[button setImage:[UIImage imageNamed:@"general"] forState:UIControlStateNormal];
	[button addTarget:self action:@selector(settingsButtonAction:) forControlEvents:UIControlEventTouchUpInside];
	return button;
}

- (void)settingsButtonAction:(UIButton *)button {

}

- (void)registerContentSizeCategoryDidChangeNotification {
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(contentSizeDidChange:) name:UIContentSizeCategoryDidChangeNotification object:nil];
}

- (void)contentSizeDidChange:(NSNotification *)notification {

}

- (void)removeObserver {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)presentSubViewController:(UIViewController *)viewController {
	if (IS_IPHONE) {
		UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
		[self presentViewController:navigationController animated:YES completion:nil];
	} else {
		A3RootViewController *rootViewController = [[A3AppDelegate instance] rootViewController];
		[rootViewController presentRightSideViewController:viewController];
	}
}

#pragma mark - Right Bar Button

- (void)rightBarButtonDoneButton {
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStylePlain target:self action:@selector(doneButtonAction:)];
}

- (void)doneButtonAction:(UIBarButtonItem *)button {

}

- (void)rightButtonMoreButton {
	UIImage *image = [UIImage imageNamed:@"more_stroke"];
	UIBarButtonItem *moreButtonItem = [[UIBarButtonItem alloc] initWithImage:[image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] style:UIBarButtonItemStylePlain target:self action:@selector(moreButtonAction:)];

	self.navigationItem.rightBarButtonItem = moreButtonItem;
}

- (void)moreButtonAction:(UIBarButtonItem *)button {

}

- (NSString *)currencyFormattedStringForCurrency:(NSString *)code value:(NSNumber *)value {
	NSNumberFormatter *nf = [[NSNumberFormatter alloc] init];
	[nf setCurrencyCode:code];
	[nf setNumberStyle:NSNumberFormatterCurrencyStyle];

	if (IS_IPHONE) {
		[nf setCurrencySymbol:@""];
	}
	return [nf stringFromNumber:value];
}

/*! This will make back bar button title @"" and this will effective for child view controllers
 * \returns void
 */
- (void)makeBackButtonEmptyArrow {
	self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
}

@end
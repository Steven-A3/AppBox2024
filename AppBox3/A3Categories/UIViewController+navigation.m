//
//  UIViewController+navigation.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 6/26/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import "CommonUIDefinitions.h"
#import "A3EmptyActionMenuViewController_iPad.h"
#import "A3BlackBarButton.h"
#import "A3BarButton.h"
#import "UIView+Screenshot.h"
#import "A3ActionMenuViewController_iPhone.h"
#import "A3ActionMenuViewController_iPad.h"
#import "UIViewController+A3AppCategory.h"
#import <objc/runtime.h>
#import "UIViewController+navigation.h"
#import "A3UIDevice.h"
#import "A3CenterViewProtocol.h"

#define A3_ACTION_MENU_COVER_VIEW_TAG		79325
static char const *const key_actionMenuViewController 			= "key_actionMenuViewController";
static char const *const key_actionMenuAnimating				= "key_actionMenuAnimating";

@implementation UIViewController (navigation)

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
	if (IS_IPHONE) {
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

- (UIBarButtonItem *)appListBarButtonItemWithSelector:(SEL)selector {
	UIBarButtonItem *sideMenuButton = [[UIBarButtonItem alloc] initWithTitle:@"Apps" style:UIBarButtonItemStylePlain target:self action:selector];
	return sideMenuButton;
}

@end

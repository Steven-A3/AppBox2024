//
//  A3CalculatorViewController_iPhone.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 9/23/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import "A3CalculatorViewController_iPhone.h"
#import "HTCopyableLabel.h"
#import "A3CalcKeyboardView_iPhone.h"
#import "FXPageControl.h"
#import "A3ExpressionComponent.h"
#import "UIViewController+A3Addition.h"
#import "UIViewController+MMDrawerController.h"
#import "Calculation.h"
#import "A3CalculatorHistoryViewController.h"
#import "A3KeyboardView.h"
#import "A3InstructionViewController.h"
#import "UIViewController+iPad_rightSideView.h"
#import "A3KeyboardButton_iOS7_iPhone.h"
#import "A3SyncManager.h"
#import "A3SyncManager+NSUbiquitousKeyValueStore.h"
#import "A3UserDefaults.h"
#import "NSManagedObject+extension.h"
#import "NSManagedObjectContext+extension.h"
#import "A3AppDelegate.h"
#import "A3UIDevice.h"

@interface A3CalculatorViewController_iPhone () <UIScrollViewDelegate, A3CalcKeyboardViewDelegate,MBProgressHUDDelegate, A3CalcMessagShowDelegate, A3InstructionViewControllerDelegate, UITextFieldDelegate>

@property (nonatomic, strong) HTCopyableLabel *expressionLabel;
@property (nonatomic, strong) UILabel *degreeRadianLabel;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) FXPageControl *pageControl;
@property (nonatomic, strong) A3CalcKeyboardView_iPhone *keyboardView;
@property (nonatomic, strong) NSArray *moreMenuButtons;
@property (nonatomic, strong) UIView *moreMenuView;
@property (nonatomic, strong) MASConstraint *scrollViewBottomConstraint;
@property (nonatomic, strong) MASConstraint *expressionTopConstraint;
@property (nonatomic, strong) MASConstraint *resultLabelHeightConstraint;
@property (nonatomic, strong) MASConstraint *resultLabelBaselineConstraint;
@property (nonatomic, strong) MASConstraint *degreeLabelBottomConstraint;
@property (nonatomic, strong) MASConstraint *expressionLabelRightConstraint;
@property (nonatomic, strong) MASConstraint *resultLabelRightConstraint;
@property (nonatomic, strong) MASConstraint *scrollViewHeightConstraint;
@property (nonatomic, strong) UIPopoverController *sharePopoverController;
@property (nonatomic, strong) UINavigationController *modalNavigationController;
@property (nonatomic, strong) A3InstructionViewController *instructionViewController;
@property (nonatomic, assign) CGFloat pageControlHeight;

@end

@implementation A3CalculatorViewController_iPhone {
    BOOL _isShowMoreMenu;

    UITapGestureRecognizer *_navGestureRecognizer;
    UIBarButtonItem *_share;
    UIBarButtonItem *_history;
    UIBarButtonItem *_help;

    UIButton *_shareButton;
    UIButton *_historyButton;
    UIButton *_helpButton;
    
    CGFloat _pageControlHeight;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        UIEdgeInsets safeAreaInsets = [[[UIApplication sharedApplication] keyWindow] safeAreaInsets];
        _pageControlHeight = safeAreaInsets.bottom != 0 ? 30 : 20;
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

- (void)viewDidLoad
{
    [super viewDidLoad];

	self.title = NSLocalizedString(A3AppName_Calculator, nil);

	if (!_modalPresentingParentViewController) {
		[self leftBarButtonAppsButton];
		[self rightBarButtons];
	} else {
		[self leftBarButtonCancelButton];
		[self rightBarButtonDoneButton];
	}
    
	[self setupSubviews];
	NSString *expression = [[A3SyncManager sharedSyncManager] objectForKey:A3CalculatorUserDefaultsSavedLastExpression];
    if (expression){
        [self.calculator setMathExpression:expression];
        [self.calculator evaluateAndSet];
        [self checkRightButtonDisable];
    }
    [self setupGestureRecognizer];
    
    if (IS_IPHONE) {
        [self setupInstructionView];
    }
    
    // Radian / Degrees 버튼 초기화
    [self.calculator setRadian:[self radian]];
    _degreeRadianLabel.text = [self radian] ? @"Rad" : @"Deg";
    [_keyboardView.radianDegreeButton setTitle:([self radian] ? @"Deg" : @"Rad") forState:UIControlStateNormal];

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cloudStoreDidImport) name:A3NotificationCloudKeyValueStoreDidImport object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cloudStoreDidImport) name:A3NotificationCloudCoreDataStoreDidImport object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
}

- (void)applicationDidEnterBackground {
	[self dismissInstructionViewController:nil];
}

- (void)cloudStoreDidImport {
	NSString *mathExpression = [[A3SyncManager sharedSyncManager] objectForKey:A3CalculatorUserDefaultsSavedLastExpression];
	if (mathExpression){
		[self.calculator setMathExpression:mathExpression];
		[self.calculator evaluateAndSet];
	}
	[self checkRightButtonDisable];
}

- (void)didMoveToParentViewController:(UIViewController *)parent {
	[super didMoveToParentViewController:parent];

	FNLOG(@"%@", parent);
	if (parent) {
		[[NSNotificationCenter defaultCenter] postNotificationName:A3NotificationChildViewControllerDidDismiss object:self];
	}
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];

    CGFloat scaleToDesign = [_keyboardView scaleToDesignForCalculator];
	_scrollView.contentOffset = CGPointMake(320 * scaleToDesign, 0);
}

- (void)removeObserver {
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:A3NotificationCloudKeyValueStoreDidImport object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:A3NotificationCloudCoreDataStoreDidImport object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];

	if ([self isMovingFromParentViewController] || [self isBeingDismissed]) {
		FNLOG();
		[self removeObserver];
	}
}

- (void)cleanUp {
	[self dismissInstructionViewController:nil];
	[self removeObserver];
}

- (BOOL)resignFirstResponder {
	NSString *startingAppName = [[A3UserDefaults standardUserDefaults] objectForKey:kA3AppsStartingAppName];
	if ([startingAppName length] && ![startingAppName isEqualToString:A3AppName_Calculator]) {
		[self.instructionViewController.view removeFromSuperview];
		self.instructionViewController = nil;
	}
	return [super resignFirstResponder];
}

- (void)dealloc {
	[self removeObserver];
}

- (void)setupGestureRecognizer {
	_navGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOnScrollView)];
	[self.view addGestureRecognizer:_navGestureRecognizer];
	if (![self hidesNavigationBar]) {
		_navGestureRecognizer.enabled = NO;
	}
}

- (void)tapOnScrollView {
	BOOL navigationBarHidden = self.navigationController.navigationBarHidden;
	[self setNavigationBarHidden:!navigationBarHidden];
}

- (void)setNavigationBarHidden:(BOOL)hidden {
	[self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
	[self.navigationController.navigationBar setShadowImage:nil];

	[self.navigationController setNavigationBarHidden:hidden];
}

- (BOOL)hidesNavigationBar {
	return ![UIWindow interfaceOrientationIsPortrait] || IS_IPHONE35;
}

- (void)toggleRadianDegree {
    if([self radian]) {
        [self.calculator setRadian:FALSE];
        self.radian = NO;
    } else {
        [self.calculator setRadian:TRUE];
        self.radian = YES;
    }
    _degreeRadianLabel.text = self.radian ? @"Rad" : @"Deg";
}

- (CGFloat)getSVbottomOffSet:(CGRect) screenBounds {
    UIEdgeInsets safeAreaInsets = [[[UIApplication sharedApplication] keyWindow] safeAreaInsets];
    if ([UIWindow interfaceOrientationIsPortrait]) {
        return -(safeAreaInsets.bottom + _pageControlHeight);
    }
    return -(safeAreaInsets.bottom);
}

- (CGFloat)getExpressionLabelTopOffSet:(CGRect) screenBounds {
    CGFloat scaleToDesign = [A3UIDevice scaleToOriginalDesignDimension];
    if ([UIWindow interfaceOrientationIsPortrait]) {
        if (screenBounds.size.height == 693) {
            // (iPhone 14 Pro, iPhone 14, iPhone 13 Pro, iPhone 12 Pro,
            // iPhone 13, iPhone 12, iPhone 12 mini, iPhone 13 mini,
            // iPhone 11 Pro, iPhone Xs, iPhone X) Zoomed
            return 95 * scaleToDesign;
        } else if (screenBounds.size.height == 480) {
            return 25.5;
        } else if (screenBounds.size.height == 568) {
            return 70 * scaleToDesign;
        } else if (screenBounds.size.height == 667 ||
                   screenBounds.size.height == 736) {
            return 90 * scaleToDesign;
        } else if (screenBounds.size.height == 812 ||
                   screenBounds.size.height == 844 ||
                   screenBounds.size.height == 852 ||
                   screenBounds.size.height == 896 ||
                   screenBounds.size.height == 926 ||
                   screenBounds.size.height == 932      // iPhone 14 Pro Max
                   ) {
            return 90 * scaleToDesign;
        }
        return 100 * scaleToDesign;
    }
    // Landscape
    return scaleToDesign * 4;
}

- (CGFloat)getExpressionLabelRightOffSet:(CGRect) screenBounds {
    UIEdgeInsets safeAreaInsets = [[[UIApplication sharedApplication] keyWindow] safeAreaInsets];

    CGFloat scaleToDesign = [A3UIDevice scaleToOriginalDesignDimension];
    if (![UIWindow interfaceOrientationIsPortrait] && safeAreaInsets.bottom > 0) {
        if ([[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationLandscapeRight) {
            return -10;
        } else {
            return -30;
        }
    }
    return [UIWindow interfaceOrientationIsPortrait] ? (screenBounds.size.height == 480 ? -6.5 : -6.5 * scaleToDesign) : 0.5 * scaleToDesign;
}

- (CGFloat)getResultLabelRightOffSet:(CGRect) screenBounds {
    UIEdgeInsets safeAreaInsets = [[[UIApplication sharedApplication] keyWindow] safeAreaInsets];
    if (![UIWindow interfaceOrientationIsPortrait] && safeAreaInsets.bottom > 0) {
        if ([[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationLandscapeRight) {
            return -10;
        } else {
            return -30;
        }
    }
    CGFloat scaleToDesign = [A3UIDevice scaleToOriginalDesignDimension];
    return [UIWindow interfaceOrientationIsPortrait] ? (screenBounds.size.height == 480 ? -15 : -14 * scaleToDesign) : -8.5 * scaleToDesign;
}

- (CGFloat)getResultLabelBaselineOffSet:(CGRect) screenBounds {
    CGFloat scaleToDesign = [A3UIDevice scaleToOriginalDesignDimension];
    if ([UIWindow interfaceOrientationIsPortrait]) {
        if (screenBounds.size.height == 812) {
            // Zoomed for iPhone 14 Pro Max, iPhone 14 Plus, iPhone 13/12 Pro Max
            // iPhone 11 Pro Max, iPhone Xs Max, iPhone 11, iPhone Xr
            return 300 * scaleToDesign;
        } else if (screenBounds.size.height == 693) {
            // (iPhone 14 Pro, iPhone 14, iPhone 13/12 Pro,
            // iPhone 13/12, iPhone 13/12 mini,
            // iPhone 11 Pro, iPhone Xs, iPhone X) Zoomed
            return 295;
        } else if (screenBounds.size.height == 480) {
            return 121;
        } else if (screenBounds.size.height == 568 ||
                   screenBounds.size.height == 667 ||
                   screenBounds.size.height == 736) {
            return 280 * scaleToDesign;
        } else if (screenBounds.size.height == 844 ||
                   screenBounds.size.height == 852 ||
                   screenBounds.size.height == 896 ||
                   screenBounds.size.height == 926 ||
                   screenBounds.size.height == 932      // iPhone 14 Pro Max
                   ) {
            return 300 * scaleToDesign;
        }
        return 280 * scaleToDesign;
    }
    // Landscape
    return scaleToDesign * 68;
}

- (UIFont *)getResultLabelFont:(CGRect) screenBounds {
    CGFloat scaleToDesign = [A3UIDevice scaleToOriginalDesignDimension];
    return [UIFont fontWithName:@"HelveticaNeue-Thin" size:![UIWindow interfaceOrientationIsPortrait] ? 44 * scaleToDesign : screenBounds.size.height == 480 ? 62 : 84 * scaleToDesign];
}

- (id)getResultLabelHeight:(CGRect) screenBounds {
    return [UIWindow interfaceOrientationIsPortrait] ? (screenBounds.size.height == 480 ? @60 : @83) : @44;
}

- (CGFloat)getNumberPadScrollViewHeight {
    CGFloat scaleToDesign = [_keyboardView scaleToDesignForCalculator];
    return ![UIWindow interfaceOrientationIsPortrait] ? 240 * scaleToDesign + 1 : 324 * scaleToDesign;
}

- (void)setupSubviews {
	self.view.backgroundColor = [UIColor whiteColor];

	CGRect screenBounds = [self screenBoundsAdjustedWithOrientation];
	CGFloat scale = [A3UIDevice scaleToOriginalDesignDimension];
    CGFloat keyboardHeight = [self getNumberPadScrollViewHeight];

	[self.view addSubview:self.scrollView];
	[_scrollView makeConstraints:^(MASConstraintMaker *make) {
		make.left.equalTo(self.view.left);
		make.right.equalTo(self.view.right);
		self.scrollViewHeightConstraint = make.height.equalTo(@(keyboardHeight));
		self.scrollViewBottomConstraint = make.bottom.equalTo(self.view.bottom).with.offset([self getSVbottomOffSet:screenBounds]);
	}];
    
	_keyboardView = [[A3CalcKeyboardView_iPhone alloc] initWithFrame:CGRectMake(0,0,screenBounds.size.width * 2, 324 * scale)];
	_keyboardView.delegate = self;
	[_scrollView addSubview:_keyboardView];
    
	[self.view addSubview:self.pageControl];
	[_pageControl makeConstraints:^(MASConstraintMaker *make) {
		make.left.equalTo(self.view.left);
		make.right.equalTo(self.view.right);
        UIEdgeInsets safeAreaInsets = [[[UIApplication sharedApplication] keyWindow] safeAreaInsets];
        make.bottom.equalTo(self.view.bottom).with.offset(-safeAreaInsets.bottom);
		make.height.equalTo(@(self.pageControlHeight));
	}];

	[self.view addSubview:self.evaluatedResultLabel];
	[self.evaluatedResultLabel makeConstraints:^(MASConstraintMaker *make) {
		make.left.equalTo(self.view.left).with.offset(14);
        self.resultLabelRightConstraint = make.right.equalTo(self.view.right).with.offset([self getResultLabelRightOffSet:screenBounds]);
        self.resultLabelBaselineConstraint = make.baseline.equalTo(self.scrollView.top).with.offset([UIWindow interfaceOrientationIsPortrait] ? -20 : 5);
	}];

    [self.view addSubview:self.expressionLabel];
    [_expressionLabel makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.left).with.offset(15);
        self.expressionLabelRightConstraint =  make.right.equalTo(self.view.right).with.offset([self getExpressionLabelRightOffSet:screenBounds]);
        make.height.equalTo(@23);
        self.expressionTopConstraint = make.top.equalTo(self.view.top).with.offset([self getExpressionLabelTopOffSet:screenBounds]);
    }];
    

    [self setDegAndRad:YES];

    self.calculator = [[A3Calculator alloc] initWithLabel:_expressionLabel result:self.evaluatedResultLabel];
    self.calculator.delegate = self;

	[self.view layoutIfNeeded];

}

- (void)setDegAndRad:(BOOL)bFirst {
    if (!bFirst) {
        [_degreeRadianLabel removeFromSuperview];
    }
    
    if (![UIWindow interfaceOrientationIsPortrait]) {
		[self.view addSubview:self.degreeRadianLabel];
        [_degreeRadianLabel makeConstraints:^(MASConstraintMaker *make) {
            CGFloat leftOffset = 12;
            UIEdgeInsets safeAreaInsets = [[[UIApplication sharedApplication] keyWindow] safeAreaInsets];
            if (safeAreaInsets.bottom > 0) {
                if ([[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationLandscapeRight) {
                    leftOffset = 42;
                }
            }
			make.left.equalTo(self.view.left).with.offset(leftOffset);
			make.bottom.equalTo(self.keyboardView.top).with.offset(-8.0);
		}];
    } else {
		[self.pageControl addSubview:self.degreeRadianLabel];
        [_degreeRadianLabel makeConstraints:^(MASConstraintMaker *make) {
			make.left.equalTo(self.pageControl.left).with.offset(12);
            make.centerY.equalTo(self.pageControl.centerY);
		}];
    }
}

- (HTCopyableLabel *)expressionLabel {
	if (!_expressionLabel) {
		_expressionLabel = [HTCopyableLabel new];
		_expressionLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:15];
		_expressionLabel.textColor = [UIColor colorWithRed:159.0/255.0 green:159.0/255.0 blue:159.0/255.0 alpha:1.0];
		_expressionLabel.textAlignment = NSTextAlignmentRight;
		_expressionLabel.text = @"";
        _expressionLabel.copyingEnabled = NO;
		_expressionLabel.lineBreakMode = NSLineBreakByTruncatingHead;
	}
	return _expressionLabel;
}

- (HTCopyableLabel *)evaluatedResultLabel {
	if (!super.evaluatedResultLabel) {
		CGRect screenBounds = [self screenBoundsAdjustedWithOrientation];
		HTCopyableLabel *evaluatedResultLabel = [HTCopyableLabel new];
		evaluatedResultLabel.font = [self getResultLabelFont:screenBounds];
		evaluatedResultLabel.textColor = [UIColor blackColor];
		evaluatedResultLabel.textAlignment = NSTextAlignmentRight;
		evaluatedResultLabel.text = @"0";
		evaluatedResultLabel.adjustsFontSizeToFitWidth = YES;
		evaluatedResultLabel.minimumScaleFactor = 0.2;

		super.evaluatedResultLabel = evaluatedResultLabel;
	}
	return super.evaluatedResultLabel;
}

- (UILabel *)degreeRadianLabel {
    if(!_degreeRadianLabel) {
        _degreeRadianLabel = [UILabel new];
        _degreeRadianLabel.font = [UIFont systemFontOfSize:14];
        _degreeRadianLabel.textColor = [UIColor colorWithRed:159.0/255.0 green:159.0/255.0 blue:159.0/255.0 alpha:1.0];
        _degreeRadianLabel.textAlignment = NSTextAlignmentLeft;
        _degreeRadianLabel.backgroundColor = [UIColor clearColor];
//        _degreeRadianLabel.baselineAdjustment = UIBaselineAdjustmentAlignBaselines;
        _degreeRadianLabel.text = self.radian ? @"Rad" : @"Deg";
    }
    
    return _degreeRadianLabel;
}

- (UIScrollView *)scrollView {
	if (!_scrollView) {
		_scrollView = [UIScrollView new];
		_scrollView.showsVerticalScrollIndicator = NO;
		_scrollView.showsHorizontalScrollIndicator = NO;
		_scrollView.pagingEnabled = YES;
		_scrollView.directionalLockEnabled = YES;
        _scrollView.bounces = NO;
		_scrollView.contentSize = CGSizeMake(640, 324);
		_scrollView.delegate = self;
	}
	return _scrollView;
}

- (FXPageControl *)pageControl {
	if (!_pageControl) {
		_pageControl = [[FXPageControl alloc] init];
		_pageControl.backgroundColor = [UIColor colorWithRed:239.0/255.0 green:239.0/255.0 blue:244.0/255.0 alpha:1.0];
		_pageControl.numberOfPages = 2;
		_pageControl.dotColor = [UIColor colorWithRed:128.0 / 255.0 green:128.0 / 255.0 blue:128.0 / 255.0 alpha:1.0];
		_pageControl.selectedDotColor = [UIColor blackColor];
		_pageControl.dotSpacing = 9;
		_pageControl.currentPage = 1;
		[_pageControl addTarget:self action:@selector(pageControlValueChanged) forControlEvents:UIControlEventValueChanged];
	}
	return _pageControl;
}

- (void)pageControlValueChanged {
	CGRect screenBounds = [A3UIDevice screenBoundsAdjustedWithOrientation];
	[_scrollView setContentOffset:CGPointMake(_pageControl.currentPage * screenBounds.size.width, 0) animated:YES];
    if([self hidesNavigationBar]) {
        [self setNavigationBarHidden:NO];
    }
}

- (NSUInteger)a3SupportedInterfaceOrientations {
	if (IS_IPHONE && [[A3AppDelegate instance] isMainMenuStyleList] && self.mm_drawerController.openSide == MMDrawerSideLeft) {
		return UIInterfaceOrientationMaskPortrait;
	}
	
    return UIInterfaceOrientationMaskAllButUpsideDown;
}

- (BOOL)prefersStatusBarHidden {
    return NO;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleDefault;
}

- (void)viewWillLayoutSubviews {
    FNLOG();
    
    CGRect screenBounds = [self screenBoundsAdjustedWithOrientation];
    
    CGFloat scaleToDesign = [A3UIDevice scaleToOriginalDesignDimension];
    if ([UIWindow interfaceOrientationIsPortrait]) {
        CGRect frame = _keyboardView.frame;
        frame.origin.x = 0.0;
        frame.origin.y = 0.0;
        frame.size.width = screenBounds.size.width * 2;
        frame.size.height = 324.0 * scaleToDesign;
        _keyboardView.frame = frame;
        _scrollView.contentSize = CGSizeMake(screenBounds.size.width * 2, 324 * scaleToDesign);
        _scrollView.scrollEnabled = YES;
        [self pageControlValueChanged]; // to move the previsous page of keyboard before rotating.
        if ([self hidesNavigationBar]) {
            _navGestureRecognizer.enabled = YES;
            [self setNavigationBarHidden:YES];
        } else {
            _navGestureRecognizer.enabled = NO;
            [self setNavigationBarHidden:NO];
        }
        self.pageControl.hidden = NO;

        [self setNeedsStatusBarAppearanceUpdate];

        self.calculator.isLandScape = NO;
    }
    else {
        if (_instructionViewController) {
            [self dismissInstructionViewController:nil];
        }
        
        CGRect frame = _keyboardView.frame;
        frame.size.width = screenBounds.size.width;
        frame.size.height = [self getNumberPadScrollViewHeight];
        
        // iPhone X
        UIEdgeInsets safeAreaInsets = [[[UIApplication sharedApplication] keyWindow] safeAreaInsets];
        if (safeAreaInsets.bottom > 0) {
            if ([[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationLandscapeRight) {
                frame.origin.x = safeAreaInsets.left - 14;
                frame.size.width -= safeAreaInsets.left - 14;
            } else {
                frame.origin.x = 0.0;
                frame.size.width -= safeAreaInsets.right - 14;
            }
            frame.size.height = [self getNumberPadScrollViewHeight];
        }
        
        frame.origin.y = 0.0;
        _keyboardView.frame = frame;
        
        self.pageControl.hidden = YES;
        
        _scrollView.contentSize = CGSizeMake(screenBounds.size.width, frame.size.height);
        _scrollView.scrollEnabled = NO;
        _navGestureRecognizer.enabled = NO;

		FNLOG(@"%@", self.presentedViewController);

		if (!self.presentedViewController) {
			[self setNavigationBarHidden:YES];
            [self setNeedsStatusBarAppearanceUpdate];
		}
		
        self.calculator.isLandScape = YES;
    }
    self.evaluatedResultLabel.font = [self getResultLabelFont:screenBounds];
    self.scrollViewBottomConstraint.offset([self getSVbottomOffSet:screenBounds]);
    self.expressionTopConstraint.offset([self getExpressionLabelTopOffSet:screenBounds]);
    self.expressionLabelRightConstraint.offset([self getExpressionLabelRightOffSet:screenBounds]);
    self.resultLabelBaselineConstraint.offset([UIWindow interfaceOrientationIsPortrait] ? -30 : -5);
    self.resultLabelRightConstraint.offset([self getResultLabelRightOffSet:screenBounds]);
    // self.degreeLabelBottomConstraint.offset([self getDegreeLabelBottomOffset:screenBounds]);
    self.scrollViewHeightConstraint.equalTo(@([self getNumberPadScrollViewHeight]));
    
    [self setDegAndRad:NO];
    [self.calculator evaluateAndSet];
    [_keyboardView layoutIfNeeded];
    
    [self checkRightButtonDisable];
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        [self viewWillLayoutSubviews];
    } completion:nil];
}

#pragma mark Instruction Related

static NSString *const A3V3InstructionDidShowForCalculator = @"A3V3InstructionDidShowForCalculator";

- (void)setupInstructionView
{
    if (![[A3UserDefaults standardUserDefaults] boolForKey:A3V3InstructionDidShowForCalculator]) {
        [self showInstructionView];
    }
}

- (void)showInstructionView
{
    [self dismissMoreMenu];
    
    if (![UIWindow interfaceOrientationIsPortrait]) {
        return;
    }

	[[A3UserDefaults standardUserDefaults] setBool:YES forKey:A3V3InstructionDidShowForCalculator];
	[[A3UserDefaults standardUserDefaults] synchronize];

	UIStoryboard *instructionStoryBoard = [UIStoryboard storyboardWithName:IS_IPHONE ? A3StoryboardInstruction_iPhone : A3StoryboardInstruction_iPad bundle:nil];
    _instructionViewController = [instructionStoryBoard instantiateViewControllerWithIdentifier:@"Calculator"];
    self.instructionViewController.delegate = self;
    [self.navigationController.view addSubview:self.instructionViewController.view];
}

- (void)dismissInstructionViewController:(UIView *)view
{
    [self.instructionViewController.view removeFromSuperview];
    self.instructionViewController = nil;
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
	CGRect screenBounds = [A3UIDevice screenBoundsAdjustedWithOrientation];
	_pageControl.currentPage = (NSInteger) ceil(_scrollView.contentOffset.x / screenBounds.size.width);
}

- (void)keyboardButtonPressed:(NSUInteger)key {
    [self dismissMoreMenu];

	NSString *expression;
    //FNLOG("text = %@ attributedText = %@", _expressionLabel.text, [_expressionLabel.attributedText string]);
    if([self hidesNavigationBar]) {
        [self setNavigationBarHidden:YES];
    }
    if(key == A3E_CALCULATE){
        expression =_expressionLabel.text;
    }

    if(key == A3E_RADIAN_DEGREE)
    {
		[self toggleRadianDegree];
    }
    else {
        [self.calculator keyboardButtonPressed:key];
        if(key == A3E_CALCULATE) {
            [self putCalculationHistoryWithExpression:expression];
        }
    }
    [self checkRightButtonDisable];
}

#pragma mark - Right Button more

- (void) rightBarButtons {
    if (IS_IPHONE) {
        [self rightButtonMoreButton];
    }
    else {
        _share = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"share"] style:UIBarButtonItemStylePlain target:self action:@selector(shareButtonAction:)];
        _history = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"history"] style:UIBarButtonItemStylePlain target:self action:@selector(historyButtonAction:)];
        _help = [self instructionHelpBarButton];
        self.navigationItem.rightBarButtonItems = @[_history, _share, _help];
        [self checkRightButtonDisable];
    }
}

- (void)moreButtonAction:(UIBarButtonItem *)button {
	[self rightBarButtonDoneButton];

    _shareButton = [self shareButton];
    _historyButton = [self historyButton:nil];
    _helpButton = [self instructionHelpButton];
    _moreMenuButtons = @[_helpButton, _shareButton, _historyButton];
	_moreMenuView = [self presentMoreMenuWithButtons:_moreMenuButtons pullDownView:nil];
	_isShowMoreMenu = YES;
    
    [self checkRightButtonDisable];
}

- (void)doneButtonAction:(id)button {
    if (!_modalPresentingParentViewController) {
        [self dismissMoreMenu];
    }
    else {
        [super doneButtonAction:button];
    }
}

- (void)dismissMoreMenu {
	if ( !_isShowMoreMenu || IS_IPAD ) return;
    
	[self moreMenuDismissAction:[[self.view gestureRecognizers] lastObject] ];
}

- (void)moreMenuDismissAction:(UITapGestureRecognizer *)gestureRecognizer {
	if (!_isShowMoreMenu) return;
    
	_isShowMoreMenu = NO;
    
	[self rightButtonMoreButton];
	[self dismissMoreMenuView:_moreMenuView pullDownView:nil completion:^{
	}];
	[self.view removeGestureRecognizer:gestureRecognizer];
}

- (BOOL) isCalculationHistoryEmpty {
    Calculation *lastcalculation = [Calculation findFirstOrderedByAttribute:@"updateDate" ascending:NO];
    if (lastcalculation != nil ) {
        return NO;
    } else {
        return YES;
    }
}

- (void) checkRightButtonDisable {
    if ([self isCalculationHistoryEmpty]) {
        _history.enabled = NO;
        _historyButton.enabled = NO;
    } else {
        _history.enabled = YES;
        _historyButton.enabled = YES;
    }
    
    if([self.expressionLabel.text length] > 0) {
        _share.enabled = YES;
        _shareButton.enabled = YES;
    } else {
        _share.enabled = NO;
        _shareButton.enabled = NO;
    }
}

- (void)shareAll:(id)sender {
	_sharePopoverController =
            [self presentActivityViewControllerWithActivityItems:@[self]
                                               fromBarButtonItem:sender
                                               completionHandler:nil];
}

- (NSString *)activityViewController:(UIActivityViewController *)activityViewController subjectForActivityType:(NSString *)activityType
{
    if ([activityType isEqualToString:UIActivityTypeMail]) {
        return NSLocalizedString(@"Calculator using AppBox Pro", @"Calculator using AppBox Pro");
    }
    return @"";
}

- (id)activityViewController:(UIActivityViewController *)activityViewController itemForActivityType:(NSString *)activityType
{
    if ([activityType isEqualToString:UIActivityTypeMail]) {
		NSString *normalString = [NSString stringWithFormat:@"%@\n\n", NSLocalizedString(@"I'd like to share a calculation with you.", nil)];
		NSMutableAttributedString *shareString = [[NSMutableAttributedString alloc] initWithString:normalString];
        NSMutableAttributedString *expression = [[NSMutableAttributedString alloc] initWithAttributedString:[self.calculator getMathAttributedExpression]];
        if ([expression length] >= 3) {
            NSRange range;
            range.location = [expression length] - 3;
            range.length = 3;
            // remove invisible string
            [expression replaceCharactersInRange:range withString:@""];
        }

        if (![[expression string] hasSuffix:@"="]) {
			NSString *formatString = [NSString stringWithFormat:@"=%@\n", [self.calculator getResultString]];
			[expression appendAttributedString:[[NSAttributedString alloc] initWithString:formatString]];
			[shareString appendAttributedString:expression];
        } else {
			[expression appendAttributedString:[[NSAttributedString alloc] initWithString:[self.calculator getResultString]]];
            [shareString appendAttributedString:expression];
        }
		NSString *shareFormat = @"\n\n%@\nhttps://itunes.apple.com/app/id318404385";
		NSString *urlString = [NSString stringWithFormat:shareFormat, NSLocalizedString(@"You can calculate more in the AppBox Pro.", nil)];
		[shareString appendAttributedString:[[NSAttributedString alloc] initWithString:urlString]];

		return shareString;
    } else {
        return [self.calculator getResultString];
    }
    
    return @"";
}


- (id)activityViewControllerPlaceholderItem:(UIActivityViewController *)activityViewController
{
    return NSLocalizedString(A3AppName_Calculator, nil);
}

- (void)shareButtonAction:(id)sender {
    [self dismissMoreMenu];
	[self shareAll:sender];
}

#pragma mark - History

- (void)historyButtonAction:(UIButton *)button {
    [self dismissMoreMenu];
    
	A3CalculatorHistoryViewController *viewController = [[A3CalculatorHistoryViewController alloc] initWithNibName:nil bundle:nil];
	viewController.calculator = self.calculator;

	_modalNavigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
	[self presentViewController:_modalNavigationController animated:YES completion:NULL];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(historyViewControllerDidDismiss) name:A3NotificationChildViewControllerDidDismiss object:viewController];
}

- (void)historyViewControllerDidDismiss {
	[[NSNotificationCenter defaultCenter] removeObserver:self name:A3NotificationChildViewControllerDidDismiss object:_modalNavigationController.childViewControllers[0]];
	_modalNavigationController = nil;
}

- (void) ShowMessage:(NSString *)message {
    MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:HUD];
    CGRect screenBounds = [self screenBoundsAdjustedWithOrientation];
    // The sample image is based on the work by http://www.pixelpressicons.com, http://creativecommons.org/licenses/by/2.5/ca/
    // Make the customViews 37 by 37 pixels for best results (those are the bounds of the build-in progress indicators)
    //HUD.customView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark.png"]] //autorelease];
    
    // Set custom view mode
    HUD.mode = MBProgressHUDModeCustomView;
    HUD.offset = CGPointMake(HUD.offset.x, -(screenBounds.size.height/4.0));
    
    HUD.delegate = self;
    HUD.label.text = message;
    
    [HUD showAnimated:YES];
    [HUD hideAnimated:YES afterDelay:3];
}

#pragma mark -- THE END

@end

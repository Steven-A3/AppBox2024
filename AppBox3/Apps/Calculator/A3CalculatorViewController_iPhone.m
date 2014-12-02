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
#import "A3Calculator.h"
#import "Calculation.h"
#import "A3CalculatorHistoryViewController.h"
#import "A3KeyboardView.h"
#import "NSAttributedString+Append.h"
#import "A3InstructionViewController.h"
#import "UIViewController+iPad_rightSideView.h"
#import "A3KeyboardButton_iOS7_iPhone.h"
#import "A3SyncManager.h"
#import "A3SyncManager+NSUbiquitousKeyValueStore.h"
#import "A3UserDefaults.h"

@interface A3CalculatorViewController_iPhone () <UIScrollViewDelegate, A3CalcKeyboardViewDelegate,MBProgressHUDDelegate, A3CalcMessagShowDelegate, A3InstructionViewControllerDelegate, UITextFieldDelegate>

@property (nonatomic, strong) HTCopyableLabel *expressionLabel;
@property (nonatomic, strong) UILabel *degreeandradianLabel;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) FXPageControl *pageControl;
@property (nonatomic, strong) A3CalcKeyboardView_iPhone *keyboardView;
@property (nonatomic, strong) A3Calculator *calculator;
@property (nonatomic, strong) NSArray *moreMenuButtons;
@property (nonatomic, strong) UIView *moreMenuView;
@property (nonatomic, strong) MASConstraint *svbottomconstraint;
@property (nonatomic, strong) MASConstraint *expressionTopconstraint;
@property (nonatomic, strong) MASConstraint *resultLabelHeightconstraint;
@property (nonatomic, strong) MASConstraint *resultLabelBaselineConstraint;
@property (nonatomic, strong) MASConstraint *degreeLabelBottomConstraint;
@property (nonatomic, strong) MASConstraint *expressionLabelRightConstraint;
@property (nonatomic, strong) MASConstraint *resultLabelRightConstraint;
@property (nonatomic, strong) MASConstraint *svheightconstraint;
@property (nonatomic, strong) UIPopoverController *sharePopoverController;
@property (nonatomic, strong) UITextField *textFieldForPlayInputClick;
@property (nonatomic, strong) A3KeyboardView *inputViewForPlayInputClick;
@property (nonatomic, strong) UINavigationController *modalNavigationController;
//@property (nonatomic, strong) A3Expression *expression;
@property (nonatomic, strong) A3InstructionViewController *instructionViewController;
@end

@implementation A3CalculatorViewController_iPhone {
    BOOL _isShowMoreMenu;

    UITapGestureRecognizer *navGestureRecognizer;
    UIBarButtonItem *share;
    UIBarButtonItem *history;
    UIBarButtonItem *help;

    UIButton *shareButton;
    UIButton *historyButton;
    UIButton *helpButton;
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
//		self.expression = [A3Expression new];
//        maximumFractionDigits = 3;
//		minimumFractionDigits = 0;
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

    self.automaticallyAdjustsScrollViewInsets = NO;
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
        [_calculator setMathExpression:expression];
        [_calculator evaluateAndSet];
        [self checkRightButtonDisable];
    }
    [self setupGestureRecognizer];
    
	_textFieldForPlayInputClick = [[UITextField alloc] initWithFrame:CGRectZero];
	_textFieldForPlayInputClick.delegate = self;
	_inputViewForPlayInputClick = [[A3KeyboardView alloc] initWithFrame:CGRectMake(0, 0, 1, 0.1)];
	_textFieldForPlayInputClick.inputView = _inputViewForPlayInputClick;
	[self.view addSubview:_textFieldForPlayInputClick];

	[_textFieldForPlayInputClick becomeFirstResponder];
    
    if (IS_IPHONE) {
        [self setupInstructionView];
    }
    
    // Radian / Degrees 버튼 초기화
    [_calculator setRadian:[self radian]];
    _degreeandradianLabel.text = [self radian] == YES ? @"Rad" : @"Deg";
    [_keyboardView.radianDegreeButton setTitle:([self radian] == YES ? @"Deg" : @"Rad") forState:UIControlStateNormal];

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cloudStoreDidImport) name:A3NotificationCloudKeyValueStoreDidImport object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cloudStoreDidImport) name:A3NotificationCloudCoreDataStoreDidImport object:nil];
}

- (void)cloudStoreDidImport {
	NSString *mathExpression = [[A3SyncManager sharedSyncManager] objectForKey:A3CalculatorUserDefaultsSavedLastExpression];
	if (mathExpression){
		[_calculator setMathExpression:mathExpression];
		[_calculator evaluateAndSet];
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

	_scrollView.contentOffset = CGPointMake(320, 0);
}

- (void)removeObserver {
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
		[self dismissInstructionViewController:nil];
	}
	return [super resignFirstResponder];
}

- (void)dealloc {
	[self removeObserver];
}

- (void)setupGestureRecognizer {
	navGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOnScrollView)];
	[self.view addGestureRecognizer:navGestureRecognizer];
	if ([self hidesNavigationBar] == NO) {
		navGestureRecognizer.enabled = NO;
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
	CGRect screenBounds = [self screenBoundsAdjustedWithOrientation];
    // in case of iphone 3.5, auto hide enabled.
    return (screenBounds.size.height == 480 ||
            screenBounds.size.height == 320);
}

-(void) radiandegreeChange {
    if([self radian] == YES) {
        [_calculator setRadian:FALSE];
        self.radian = NO;
        _degreeandradianLabel.text = @"Deg";
    } else {
        [_calculator setRadian:TRUE];
        self.radian = YES;
        _degreeandradianLabel.text = @"Rad";
    }
}

- (CGFloat) getSVbottomOffSet:(CGRect) screenBounds {
    return screenBounds.size.height == 320? 0: -20;
}


- (CGFloat) getExpressionLabelTopOffSet:(CGRect) screenBounds {
    return screenBounds.size.height != 320 ? (screenBounds.size.height == 480 ? 25.5:80): 5.5;
}

- (CGFloat) getExpressionLabelRightOffSet:(CGRect) screenBounds {
    return screenBounds.size.height != 320 ? (screenBounds.size.height == 480 ? -6.5:-6.5):0.5;
}

- (CGFloat) getResultLabelRightOffSet:(CGRect) screenBounds {
    return screenBounds.size.height != 320 ? (screenBounds.size.height == 480 ? -15:-14):-8.5;
}

- (CGFloat)getResultLabelBaselineOffSet:(CGRect) screenBounds {
    return screenBounds.size.height != 320 ? (screenBounds.size.height == 480 ? 121 : 204.5) : 68;
}

- (UIFont *) getResultLabelFont:(CGRect) screenBounds {
    return [UIFont fontWithName:@".HelveticaNeueInterface-Thin" size:screenBounds.size.height == 320 ? 44 : screenBounds.size.height == 480 ? 62: 84];
}

- (id)getResultLabelHeight:(CGRect) screenBounds {
    return screenBounds.size.height != 320 ? (screenBounds.size.height == 480 ? @60 : @83):@44;
}

/*
-(CGFloat) getDegreeLabelBottomOffset:(CGRect) screenBounds {
    return screenBounds.size.height != 320 ? (screenBounds.size.height == 480 ? -15.5:-15.5):-8.0;
}
*/
- (id)getSVHeight:(CGRect) screenBounds {
    return screenBounds.size.height == 320? @240: @324;
}

- (void)setupSubviews {
	self.view.backgroundColor = [UIColor whiteColor];

	CGRect screenBounds = [self screenBoundsAdjustedWithOrientation];

	[self.view addSubview:self.scrollView];
	[_scrollView makeConstraints:^(MASConstraintMaker *make) {
		make.left.equalTo(self.view.left);
		make.right.equalTo(self.view.right);
		self.svheightconstraint = make.height.equalTo([self getSVHeight:screenBounds]);
		self.svbottomconstraint = make.bottom.equalTo(self.view.bottom).with.offset([self getSVbottomOffSet:screenBounds]);
	}];
    
	_keyboardView = [[A3CalcKeyboardView_iPhone alloc] initWithFrame:CGRectMake(0,0,640,324)];
	_keyboardView.delegate = self;
	[_scrollView addSubview:_keyboardView];
    
	[self.view addSubview:self.pageControl];
	[_pageControl makeConstraints:^(MASConstraintMaker *make) {
		make.left.equalTo(self.view.left);
		make.right.equalTo(self.view.right);
		make.bottom.equalTo(self.view.bottom);
		make.height.equalTo(@20);
	}];

	[self.view addSubview:self.evaluatedResultLabel];
	[self.evaluatedResultLabel makeConstraints:^(MASConstraintMaker *make) {
		make.left.equalTo(self.view.left).with.offset(14);
        self.resultLabelRightConstraint = make.right.equalTo(self.view.right).with.offset([self getResultLabelRightOffSet:screenBounds]);
		self.resultLabelBaselineConstraint = make.baseline.equalTo(self.view.top).with.offset([self getResultLabelBaselineOffSet:screenBounds]);
	}];

    [self.view addSubview:self.expressionLabel];
    [_expressionLabel makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.left).with.offset(15);
        self.expressionLabelRightConstraint =  make.right.equalTo(self.view.right).with.offset([self getExpressionLabelRightOffSet:screenBounds]);
        make.height.equalTo(@23);
        self.expressionTopconstraint = make.top.equalTo(self.view.top).with.offset([self getExpressionLabelTopOffSet:screenBounds]);
    }];
    

    [self setDegAndRad:YES];

    _calculator = [[A3Calculator alloc] initWithLabel:_expressionLabel result:self.evaluatedResultLabel];
    _calculator.delegate = self;

	[self.view layoutIfNeeded];

}

- (void) setDegAndRad:(BOOL ) bFirst {
    if (!bFirst) {
        [_degreeandradianLabel removeFromSuperview];
    }
    
    if (IS_LANDSCAPE) {
        
        [self.view addSubview:self.degreeandradianLabel];
        [_degreeandradianLabel makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.view.left).with.offset(12);
            //self.degreeLabelBottomConstraint =  make.bottom.equalTo(_keyboardView.top).with.offset([self getDegreeLabelBottomOffset:screenBounds]);
            make.bottom.equalTo(_keyboardView.top).with.offset(-8.0);
        }];
    } else {
        [self.pageControl addSubview:self.degreeandradianLabel];
        [_degreeandradianLabel makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.pageControl.left).with.offset(12);
            make.bottom.equalTo(self.pageControl.bottom).with.offset(-1);
        }];
    }
}

- (HTCopyableLabel *)expressionLabel {
	if (!_expressionLabel) {
		_expressionLabel = [HTCopyableLabel new];
		_expressionLabel.font = [UIFont fontWithName:@".HelveticaNeueInterface-M3" size:15];
		_expressionLabel.textColor = [UIColor colorWithRed:159.0/255.0 green:159.0/255.0 blue:159.0/255.0 alpha:1.0];
		_expressionLabel.textAlignment = NSTextAlignmentRight;
		_expressionLabel.text = @"";
        _expressionLabel.copyingEnabled = NO;
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

- (UILabel *)degreeandradianLabel {
    if(!_degreeandradianLabel) {
        _degreeandradianLabel = [UILabel new];
        _degreeandradianLabel.font = [UIFont systemFontOfSize:14];
        _degreeandradianLabel.textColor = [UIColor colorWithRed:159.0/255.0 green:159.0/255.0 blue:159.0/255.0 alpha:1.0];
        _degreeandradianLabel.textAlignment = NSTextAlignmentLeft;
        _degreeandradianLabel.backgroundColor = [UIColor clearColor];
//        _degreeandradianLabel.baselineAdjustment = UIBaselineAdjustmentAlignBaselines;
        _degreeandradianLabel.text = @"Rad";
    }
    
    return _degreeandradianLabel;
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
	[_scrollView setContentOffset:CGPointMake(_pageControl.currentPage * 320, 0) animated:YES];
    if([self hidesNavigationBar]) {
        [self setNavigationBarHidden:NO];
    }
}

- (NSUInteger)a3SupportedInterfaceOrientations {
    if (IS_IPHONE && self.mm_drawerController.openSide == MMDrawerSideLeft) {
        return UIInterfaceOrientationMaskPortrait;
    }
    
    return UIInterfaceOrientationMaskAllButUpsideDown;
}


- (void)viewWillLayoutSubviews {
    CGRect screenBounds = [self screenBoundsAdjustedWithOrientation];
    
    if (IS_PORTRAIT) {
        CGRect frame = _keyboardView.frame;
        frame.origin.x = 0.0;
        frame.origin.y = 0.0;
        frame.size.width = 640;
        frame.size.height = 324.0;
        _keyboardView.frame = frame;
        _scrollView.contentSize = CGSizeMake(640, 324);
        _scrollView.scrollEnabled = YES;
        [self pageControlValueChanged]; // to move the previsous page of keyboard before rotating.
        if ([self hidesNavigationBar]) {
            navGestureRecognizer.enabled = YES;
            [self setNavigationBarHidden:YES];
        } else {
            navGestureRecognizer.enabled = NO;
            [self setNavigationBarHidden:NO];
        }
        self.pageControl.hidden = NO;
        [[UIApplication sharedApplication] setStatusBarHidden:NO];
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
        _inputViewForPlayInputClick.backgroundColor = [UIColor colorWithRed:239.0/255.0 green:239.0/255.0 blue:244.0/255.0 alpha:1.0];
        self.calculator.isLandScape = NO;
    }
    else {
        if (_instructionViewController) {
            [self dismissInstructionViewController:nil];
        }
        
        CGRect frame = _keyboardView.frame;
        frame.origin.x = 0.0;
        frame.size.width = screenBounds.size.width;
        frame.size.height = 240.0;
        frame.origin.y = 0.0;
        _keyboardView.frame = frame;
        
        self.pageControl.hidden = YES;
        
        _scrollView.contentSize = CGSizeMake(screenBounds.size.width, 240.0);
        _scrollView.scrollEnabled = NO;
        navGestureRecognizer.enabled = NO;
        
        [self setNavigationBarHidden:YES];
        [[UIApplication sharedApplication] setStatusBarHidden:YES];
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
        _inputViewForPlayInputClick.backgroundColor = [UIColor colorWithRed:252.0 / 255.0 green:252.0 / 255.0 blue:253.0 / 255.0 alpha:1.0];
        self.calculator.isLandScape = YES;
    }
    self.evaluatedResultLabel.font = [self getResultLabelFont:screenBounds];
    self.svbottomconstraint.offset([self getSVbottomOffSet:screenBounds]);
    self.expressionTopconstraint.offset([self getExpressionLabelTopOffSet:screenBounds]);
    self.expressionLabelRightConstraint.offset([self getExpressionLabelRightOffSet:screenBounds]);
    self.resultLabelBaselineConstraint.offset([self getResultLabelBaselineOffSet:screenBounds]);
    self.resultLabelRightConstraint.offset([self getResultLabelRightOffSet:screenBounds]);
    //self.degreeLabelBottomConstraint.offset([self getDegreeLabelBottomOffset:screenBounds]);
    self.svheightconstraint.equalTo([self getSVHeight:screenBounds]);
    
    [self setDegAndRad:NO];
    [self.calculator evaluateAndSet];
    [_keyboardView layoutIfNeeded];
    
    [self checkRightButtonDisable];
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
    
    if (IS_LANDSCAPE) {
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
	_pageControl.currentPage = (NSInteger) ceil(_scrollView.contentOffset.x / 320.0);
}

- (void)keyboardButtonPressed:(NSUInteger)key {
	[_textFieldForPlayInputClick becomeFirstResponder];
	[[UIDevice currentDevice] playInputClick];
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
        [self radiandegreeChange];
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
        share = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"share"] style:UIBarButtonItemStylePlain target:self action:@selector(shareButtonAction:)];
        history = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"history"] style:UIBarButtonItemStylePlain target:self action:@selector(historyButtonAction:)];
        help = [self instructionHelpBarButton];
        self.navigationItem.rightBarButtonItems = @[history, share, help];
        [self checkRightButtonDisable];
    }
}

- (void)moreButtonAction:(UIBarButtonItem *)button {
	[self rightBarButtonDoneButton];

    shareButton = [self shareButton];
    historyButton = [self historyButton:nil];
    helpButton = [self instructionHelpButton];
    _moreMenuButtons = @[helpButton, shareButton, historyButton];
	_moreMenuView = [self presentMoreMenuWithButtons:_moreMenuButtons tableView:nil];
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
	[self dismissMoreMenuView:_moreMenuView scrollView:nil];
	[self.view removeGestureRecognizer:gestureRecognizer];
}

- (BOOL) isCalculationHistoryEmpty {
    Calculation *lastcalculation = [Calculation MR_findFirstOrderedByAttribute:@"updateDate" ascending:NO];
    if (lastcalculation != nil ) {
        return NO;
    } else {
        return YES;
    }
}

- (void) checkRightButtonDisable {
    if ([self isCalculationHistoryEmpty]) {
        history.enabled = NO;
        historyButton.enabled = NO;
    } else {
        history.enabled = YES;
        historyButton.enabled = YES;
    }
    
    if([self.expressionLabel.text length] > 0) {
        share.enabled = YES;
        shareButton.enabled = YES;
    } else {
        share.enabled = NO;
        shareButton.enabled = NO;
    }
}

- (void)shareAll:(id)sender {
	_sharePopoverController = [self presentActivityViewControllerWithActivityItems:@[self] fromBarButtonItem:sender completionHandler:nil];
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
		NSAttributedString *shareString = [[NSAttributedString alloc] initWithString:normalString];
        NSMutableAttributedString *expression = [[NSMutableAttributedString alloc] initWithAttributedString:[self.calculator getMathAttributedExpression]];
        if ([expression length] >= 3) {
            NSRange range;
            range.location = [expression length] - 3;
            range.length = 3;
            // remove invisible string
            [expression replaceCharactersInRange:range withString:@""];
        }

        if (![[expression string] hasSuffix:@"="]) {
            shareString = [shareString appendWith:[expression appendWithString:[NSString stringWithFormat:@"=%@\n", [self.calculator getResultString]]]];
        } else {
            shareString = [shareString appendWith:[expression appendWithString:[self.calculator getResultString]]];
            
        }
		NSString *shareFormat = @"\n\n%@\nhttps://itunes.apple.com/app/id318404385";
		shareString = [shareString appendWithString:[NSString stringWithFormat:shareFormat, NSLocalizedString(@"You can calculate more in the AppBox Pro.", nil)]];
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

- (void)putCalculationHistoryWithExpression:(NSString *)expression{
	NSString *mathExpression = [self.calculator getMathExpression];
	Calculation *lastcalculation = [Calculation MR_findFirstOrderedByAttribute:@"updateDate" ascending:NO];

	// Compare code and value.
	if (lastcalculation) {
		if ([lastcalculation.expression isEqualToString:mathExpression]) {
			return;
		}
	}

	Calculation *calculation = [Calculation MR_createEntityInContext:[NSManagedObjectContext MR_rootSavingContext]];
	calculation.uniqueID = [[NSUUID UUID] UUIDString];
	NSDate *keyDate = [NSDate date];
	calculation.expression = mathExpression;
	calculation.result = [self.calculator getResultString];
	calculation.updateDate = keyDate;

	[[NSManagedObjectContext MR_rootSavingContext] MR_saveOnlySelfAndWait];
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
    HUD.yOffset = -(screenBounds.size.height/4.0);
    
    HUD.delegate = self;
    HUD.labelText = message;
    
    [HUD show:YES];
    [HUD hide:YES afterDelay:3];
}

#pragma mark -- THE END

@end

//
//  A3CalculatorViewController_iPad.m
//  A3TeamWork
//
//  Created by Soon Gyu Kim on 12/24/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import "A3CalculatorViewController_iPad.h"
#import "UIViewController+A3Addition.h"
#import "HTCopyableLabel.h"
#import "A3CalculatorButtonsInBasicViewController_iPad.h"
#import "A3CalculatorButtonsInScientificViewController_iPad.h"
#import "A3Calculator.h"
#import "Calculation.h"
#import "A3ExpressionComponent.h"
#import "A3CalculatorHistoryViewController.h"
#import "A3KeyboardView.h"
#import "NSAttributedString+Append.h"
#import "UIViewController+NumberKeyboard.h"
#import "UIViewController+iPad_rightSideView.h"
#import "A3SyncManager.h"
#import "A3SyncManager+NSUbiquitousKeyValueStore.h"

NSString *const A3CalculatorModeBasic = @"basic";
NSString *const A3CalculatorModeScientific = @"scientific";

@interface A3CalculatorViewController_iPad ()<A3CalcKeyboardViewIPadDelegate, UIPopoverControllerDelegate, MBProgressHUDDelegate, A3CalcMessagShowDelegate, UITextFieldDelegate>
@property (nonatomic, strong) HTCopyableLabel *expressionLabel;
@property (nonatomic, strong) HTCopyableLabel *evaluatedResultLabel;
@property (nonatomic, strong) UILabel *degreeandradianLabel;
//@property (nonatomic, strong) UIView *outline;
@property (nonatomic, strong) A3Calculator *calculator;
@property (strong, nonatomic) A3CalculatorButtonsViewController_iPad *calculatorkeypad;
@property (nonatomic, strong) MASConstraint *calctopconstraint;
@property (nonatomic, strong) NSArray *moreMenuButtons;
@property (nonatomic, strong) UIView *moreMenuView;
@property (nonatomic, strong) UIPopoverController *sharePopoverController;
@property (nonatomic, strong) UITextField *textFieldForPlayInputClick;
@property (nonatomic, strong) A3KeyboardView *inputViewForPlayInputClick;
@property (nonatomic, strong) UISegmentedControl *calculatorTypeSegment;

@end

@implementation A3CalculatorViewController_iPad {
    BOOL scientific;

    BOOL _isShowMoreMenu;
    UIBarButtonItem *_share;
    UIBarButtonItem *_history;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

	self.title = NSLocalizedString(@"Calculator", @"Calculator");

    // Do any additional setup after loading the view from its nib.
	if (!_modalPresentingParentViewController) {
		[self leftBarButtonAppsButton];
		[self rightBarButtons];
	} else {
		[self leftBarButtonCancelButton];
		[self rightBarButtonDoneButton];
	}
	self.navigationItem.hidesBackButton = YES;
    
    [self setupSubViews];

	NSString *expression = [[A3SyncManager sharedSyncManager] objectForKey:A3CalculatorUserDefaultsSavedLastExpression];
    if (expression){
        [_calculator setMathExpression:expression];
        [_calculator evaluateAndSet];
        [self checkRightButtonDisable];
    }

	[self addTextFieldForPlayInputClick];
    
    if (IS_IPAD) {
        self.navigationItem.titleView = self.calculatorTypeSegment;
    }

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mainMenuDidHide) name:A3NotificationMainMenuDidHide object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(rightViewWillHide) name:A3NotificationRightSideViewWillDismiss object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cloudStoreDidImport) name:A3NotificationCloudKeyValueStoreDidImport object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cloudStoreDidImport) name:A3NotificationCloudCoreDataStoreDidImport object:nil];

    // Radian / Degrees 버튼 초기화
    [_calculator setRadian:[self radian]];
    _degreeandradianLabel.text = [self radian] == YES ? @"Radian" : @"Degrees";
    [_calculatorkeypad.radbutton setTitle:[self radian] == YES ? @"Deg" : @"Rad" forState:UIControlStateNormal];
}

- (void)cloudStoreDidImport {
	NSString *mathExpression = [[A3SyncManager sharedSyncManager] objectForKey:A3CalculatorUserDefaultsSavedLastExpression];
	if (mathExpression){
		[_calculator setMathExpression:mathExpression];
		[_calculator evaluateAndSet];
	}
	[self checkRightButtonDisable];
}

- (UISegmentedControl *)calculatorTypeSegment
{
    if (!_calculatorTypeSegment) {
        _calculatorTypeSegment = [[UISegmentedControl alloc] initWithItems:@[NSLocalizedString(@"Basic", @"Basic"), NSLocalizedString(@"Scientific", @"Scientific")]];
        
        [_calculatorTypeSegment setWidth:IS_IPAD ? 150:85 forSegmentAtIndex:0];
        [_calculatorTypeSegment setWidth:IS_IPAD ? 150:85 forSegmentAtIndex:1];
        
        _calculatorTypeSegment.selectedSegmentIndex = 0;
        [_calculatorTypeSegment addTarget:self action:@selector(calculatorTypeSegmentChanged:) forControlEvents:UIControlEventValueChanged];
    }
    
    return _calculatorTypeSegment;
}

- (void)calculatorTypeSegmentChanged:(UISegmentedControl*)segment {
    [_calculatorkeypad.view removeFromSuperview];
    [_calculatorkeypad removeFromParentViewController];
    _calculatorkeypad.view = nil;
    _calculatorkeypad = nil;
    
    
    if (segment.selectedSegmentIndex == 1)
    {
        scientific = YES;
		[self setupScientificKeyPad];
        [_calculatorkeypad.radbutton setTitle:[self radian] == YES ? @"Deg" : @"Rad" forState:UIControlStateNormal];
    }
    else
    {
        scientific = NO;
        [self setupBasicKeyPad];
        
    }

	[[A3SyncManager sharedSyncManager] setObject:scientific ? A3CalculatorModeScientific : A3CalculatorModeBasic forKey:A3CalculatorUserDefaultsCalculatorMode state:A3DataObjectStateModified];
//    [self changeCalculatorKindString];
}

- (void)removeObserver {
	[[NSNotificationCenter defaultCenter] removeObserver:self name:A3NotificationCloudKeyValueStoreDidImport object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:A3NotificationCloudCoreDataStoreDidImport object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:A3NotificationMainMenuDidHide object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:A3NotificationRightSideViewWillDismiss object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];

	if ([self isMovingFromParentViewController] || [self isBeingDismissed]) {
		FNLOG();
		[self removeObserver];
	}
}

- (void)cleanUp {
	[self removeObserver];
}

- (void)dealloc {
	[self removeObserver];
}

- (void)addTextFieldForPlayInputClick {
	_textFieldForPlayInputClick = [[UITextField alloc] initWithFrame:CGRectZero];
	_textFieldForPlayInputClick.delegate = self;
	_inputViewForPlayInputClick = [[A3KeyboardView alloc] initWithFrame:CGRectMake(0, 0, 1, 0.1)];
	_textFieldForPlayInputClick.inputView = _inputViewForPlayInputClick;
	[self.view addSubview:_textFieldForPlayInputClick];

	[_textFieldForPlayInputClick becomeFirstResponder];
}

- (void)rightBarButtons {
	_share = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"share"] style:UIBarButtonItemStylePlain target:self action:@selector(shareButtonAction:)];
	_share.tag = A3RightBarButtonTagShareButton;
	_history = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"history"] style:UIBarButtonItemStylePlain target:self action:@selector(historyButtonAction:)];
	_history.tag = A3RightBarButtonTagHistoryButton;
	UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
	space.width = 24.0;

	self.navigationItem.rightBarButtonItems = @[_history, space, _share];
	[self checkRightButtonDisable];
}

- (void)appsButtonAction:(UIBarButtonItem *)barButtonItem {
	[super appsButtonAction:barButtonItem];

	[self enableControls:!self.A3RootViewController.showLeftView];
}

- (void)mainMenuDidHide {
	[self enableControls:YES];
}

- (void)rightViewWillHide {
	[self enableControls:YES];
}

- (void)enableControls:(BOOL)enable {
	if (!IS_IPAD) return;
	[self.navigationItem.leftBarButtonItem setEnabled:enable];
	if (enable) {
		[self.navigationItem.rightBarButtonItems enumerateObjectsUsingBlock:^(UIBarButtonItem *barButtonItem, NSUInteger idx, BOOL *stop) {
			switch (barButtonItem.tag) {
				case A3RightBarButtonTagShareButton:
					[barButtonItem setEnabled:[self.expressionLabel.text length] > 0];
					break;
				case A3RightBarButtonTagHistoryButton:
					[barButtonItem setEnabled:![self isCalculationHistoryEmpty]];
					break;
			}
		}];
	} else {
		[self.navigationItem.rightBarButtonItems enumerateObjectsUsingBlock:^(UIBarButtonItem *barButtonItem, NSUInteger idx, BOOL *stop) {
			[barButtonItem setEnabled:NO];
		}];
	}
}

- (BOOL)usesFullScreenInLandscape {
    return YES;
}

- (void) setupSubViews {
    self.view.backgroundColor = [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0];
    CGRect screenBounds = [self screenBoundsAdjustedWithOrientation];

    [self.view addSubview:self.evaluatedResultLabel];
	[self.evaluatedResultLabel makeConstraints:^(MASConstraintMaker *make) {
		make.left.equalTo(self.view.left).with.offset(85);
		make.right.equalTo(self.view.right).with.offset(-15);
        self.calctopconstraint =  make.bottom.equalTo(self.view.top).with.offset(screenBounds.size.height == 768 ? 389:566);
		make.height.equalTo(@110);
	}];
    
    [self.view addSubview:self.expressionLabel];
	[_expressionLabel makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.left).with.offset(15);
        make.right.equalTo(self.view.right).with.offset(-2.5);
        make.top.equalTo(@91);
        make.height.equalTo(@33.5);
	}];
    
    [self.view addSubview:self.degreeandradianLabel];
    [_degreeandradianLabel makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.left).with.offset(15);
        make.bottom.equalTo(self.evaluatedResultLabel.bottom).with.offset(-9.5);
    }];
    
    _calculator = [[A3Calculator alloc] initWithLabel:_expressionLabel result:self.evaluatedResultLabel];
    _calculator.delegate = self;
    
    
    [self.view layoutIfNeeded];

    [self checkRightButtonDisable];
	NSString *modeString = [[A3SyncManager sharedSyncManager] objectForKey:A3CalculatorUserDefaultsCalculatorMode];
    if (modeString){
        if([modeString isEqualToString:A3CalculatorModeScientific]) {
			[self setupScientificKeyPad];
            self.calculatorTypeSegment.selectedSegmentIndex = 1;
        } else {
            [self setupBasicKeyPad];
            self.calculatorTypeSegment.selectedSegmentIndex = 0;
        }
    }
    else {
        [self setupBasicKeyPad];
    }

}

- (void) setupBasicKeyPad {
    scientific  = NO;

    _calculatorkeypad  = [[A3CalculatorButtonsInBasicViewController_iPad alloc] initWithNibName:@"A3CalculatorButtonsInBasicViewController_iPad" bundle:nil];

    [self.view addSubview:_calculatorkeypad.view];
    [self addChildViewController:_calculatorkeypad];

    _degreeandradianLabel.hidden = YES;
    _calculatorkeypad.delegate = self;
    _calculatorkeypad.view.clipsToBounds = YES;
}
     
- (void)setupScientificKeyPad {
    scientific  = YES;
    
    _calculatorkeypad  = [[A3CalculatorButtonsInScientificViewController_iPad alloc] initWithNibName:@"A3CalculatorButtonsInScientificViewController_iPad" bundle:nil];
	[self.view addSubview:_calculatorkeypad.view];
    [self addChildViewController:_calculatorkeypad];
    
    _calculatorkeypad.delegate = self;
    _degreeandradianLabel.hidden = NO;
    _calculatorkeypad.view.clipsToBounds = YES;
}

-(void) radiandegreeChange {
    if([self radian] == YES) {
        [_calculator setRadian:FALSE];
        self.radian = NO;
        _degreeandradianLabel.text = @"Degrees";
    } else {
        [_calculator setRadian:TRUE];
        self.radian = YES;
        _degreeandradianLabel.text = @"Radian";
    }
}

- (HTCopyableLabel *)evaluatedResultLabel {
	if (!super.evaluatedResultLabel) {
		HTCopyableLabel *evaluatedResultLabel = [HTCopyableLabel new];
		evaluatedResultLabel.backgroundColor = [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0];
		evaluatedResultLabel.font = [UIFont fontWithName:@".HelveticaNeueInterface-Thin" size:110];
		evaluatedResultLabel.textColor = [UIColor colorWithRed:0.0/255.0 green:0.0/255.0 blue:0.0/255.0 alpha:1.0];
		evaluatedResultLabel.textAlignment = NSTextAlignmentRight;
		evaluatedResultLabel.text = @"0";
		evaluatedResultLabel.adjustsFontSizeToFitWidth = YES;
		evaluatedResultLabel.minimumScaleFactor = 0.2;
		super.evaluatedResultLabel = evaluatedResultLabel;
	}
	return super.evaluatedResultLabel;
}

- (HTCopyableLabel *)expressionLabel {
	if (!_expressionLabel) {
		_expressionLabel = [HTCopyableLabel new];
        _expressionLabel.copyingEnabled = NO;
		_expressionLabel.backgroundColor =[UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0];
		_expressionLabel.font = [UIFont fontWithName:@".HelveticaNeueInterface-M3" size:22];
		_expressionLabel.textColor = [UIColor colorWithRed:159.0/255.0 green:159.0/255.0 blue:159.0/255.0 alpha:1.0];
		_expressionLabel.textAlignment = NSTextAlignmentRight;
		_expressionLabel.text = @"";
	}
	return _expressionLabel;
}


- (UILabel *)degreeandradianLabel {
    if(!_degreeandradianLabel) {
        _degreeandradianLabel = [UILabel new];
        _degreeandradianLabel.backgroundColor = [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0];
        _degreeandradianLabel.font = [UIFont fontWithName:@"HelvecticaNeue-Light" size:22];
        _degreeandradianLabel.textColor = [UIColor colorWithRed:159.0/255.0 green:159.0/255.0 blue:159.0/255.0 alpha:1.0];
        _degreeandradianLabel.textAlignment = NSTextAlignmentLeft;
        _degreeandradianLabel.text = @"Radian";
    }
    
    return _degreeandradianLabel;
}

- (void)didReceiveMemoryWarningo
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillLayoutSubviews {
    CGRect screenBounds = [self screenBoundsAdjustedWithOrientation];
    
    if (scientific == NO)
    {
        self.calctopconstraint.offset(screenBounds.size.height == 768 ? 404.5:581.5);
    }
    else {
        self.calctopconstraint.offset(screenBounds.size.height == 768 ? 273.5:413.5);
    }
    
    if (IS_LANDSCAPE) {
        self.calculator.isLandScape = YES;
    } else {
        
        self.calculator.isLandScape = NO;
    }
    
    [self.calculator evaluateAndSet];
}

- (void)keyboardButtonPressed:(NSUInteger)key {
	[_textFieldForPlayInputClick becomeFirstResponder];
	[[UIDevice currentDevice] playInputClick];

	NSString *expression;
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

- (void)shareAll:(id)sender {
	_sharePopoverController = [self presentActivityViewControllerWithActivityItems:@[self] fromBarButtonItem:sender completion:^{
		[self enableControls:YES];
	}];
	_sharePopoverController.delegate = self;
	[self.navigationItem.rightBarButtonItems enumerateObjectsUsingBlock:^(UIBarButtonItem *buttonItem, NSUInteger idx, BOOL *stop) {
		[buttonItem setEnabled:NO];
	}];
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
    return NSLocalizedString(@"Calculator", @"Calculator");
}

#pragma mark -

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController {
	_sharePopoverController = nil;
	[self enableControls:YES];
}


- (void)shareButtonAction:(id)sender {
	[self shareAll:sender];

	[self enableControls:NO];
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
        _history.enabled = NO;
    } else {
        _history.enabled = YES;
    }
    
    if([self.expressionLabel.text length] > 0) {
        _share.enabled = YES;
    } else {
        _share.enabled = NO;
    }
}

#pragma mark - History

- (void)historyButtonAction:(UIButton *)button {
	[self enableControls:NO];

	A3CalculatorHistoryViewController *viewController = [[A3CalculatorHistoryViewController alloc] initWithNibName:nil bundle:nil];
	viewController.calculator = self.calculator;
	viewController.iPadViewController = self;

	[self.A3RootViewController presentRightSideViewController:viewController];
}

- (void)putCalculationHistoryWithExpression:(NSString *)expression{
	Calculation *lastcalculation = [Calculation MR_findFirstOrderedByAttribute:@"updateDate" ascending:NO];
	NSString *mathExpression = [self.calculator getMathExpression];
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
	calculation.result = self.evaluatedResultLabel.text;
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

@end

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
#import "A3ExpressionComponent.h"
#import "A3CalculatorHistoryViewController.h"
#import "A3KeyboardView.h"
#import "UIViewController+NumberKeyboard.h"
#import "UIViewController+iPad_rightSideView.h"
#import "A3SyncManager.h"
#import "A3SyncManager+NSUbiquitousKeyValueStore.h"
#import "NSManagedObject+extension.h"
#import "NSManagedObjectContext+extension.h"
#import "A3AppDelegate.h"
#import "UIViewController+extension.h"
#import "A3UIDevice.h"
#import "AppBox3-Swift.h"

NSString *const A3CalculatorModeBasic = @"basic";
NSString *const A3CalculatorModeScientific = @"scientific";

@interface A3CalculatorViewController_iPad ()<A3CalcKeyboardViewIPadDelegate, UIPopoverControllerDelegate, MBProgressHUDDelegate, A3CalcMessagShowDelegate, UITextFieldDelegate>

@property (nonatomic, strong) HTCopyableLabel *expressionLabel;
@property (nonatomic, strong) HTCopyableLabel *evaluatedResultLabel;
@property (nonatomic, strong) UILabel *degreeandradianLabel;
@property (strong, nonatomic) A3CalculatorButtonsViewController_iPad *calculatorkeypad;
@property (nonatomic, strong) MASConstraint *calctopconstraint;
@property (nonatomic, strong) NSArray *moreMenuButtons;
@property (nonatomic, strong) UIView *moreMenuView;
@property (nonatomic, strong) UIPopoverController *sharePopoverController;
@property (nonatomic, strong) UISegmentedControl *calculatorTypeSegment;

@end

@implementation A3CalculatorViewController_iPad {
    BOOL scientific;

    BOOL _isShowMoreMenu;
    UIBarButtonItem *_share;
    UIBarButtonItem *_history;
}

@dynamic evaluatedResultLabel;

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

	self.title = NSLocalizedString(A3AppName_Calculator, nil);

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
        [self.calculator setMathExpression:expression];
        [self.calculator evaluateAndSet];
        [self checkRightButtonDisable];
    }

    if (IS_IPAD) {
        self.navigationItem.titleView = self.calculatorTypeSegment;
    }

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mainMenuDidHide) name:A3NotificationMainMenuDidHide object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(rightViewWillHide) name:A3NotificationRightSideViewWillDismiss object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cloudStoreDidImport) name:A3NotificationCloudKeyValueStoreDidImport object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cloudStoreDidImport) name:NSManagedObjectContextObjectsDidChangeNotification object:nil];

    // Radian / Degrees 버튼 초기화
    [self.calculator setRadian:[self radian]];
    _degreeandradianLabel.text = [self radian] == YES ? @"Radian" : @"Degrees";
    [_calculatorkeypad.radbutton setTitle:[self radian] == YES ? @"Deg" : @"Rad" forState:UIControlStateNormal];
}

- (void)cloudStoreDidImport {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *mathExpression = [[A3SyncManager sharedSyncManager] objectForKey:A3CalculatorUserDefaultsSavedLastExpression];
        if (mathExpression){
            [self.calculator setMathExpression:mathExpression];
            [self.calculator evaluateAndSet];
        }
        [self checkRightButtonDisable];
    });
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
	[[NSNotificationCenter defaultCenter] removeObserver:self name:NSManagedObjectContextObjectsDidChangeNotification object:nil];
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

	[self enableControls:![[A3AppDelegate instance] rootViewController_iPad].showLeftView];
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

- (void)setupSubViews {
    self.view.backgroundColor = [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0];

    [self.view addSubview:self.evaluatedResultLabel];
	[self.evaluatedResultLabel makeConstraints:^(MASConstraintMaker *make) {
		make.left.equalTo(self.view.left).with.offset(85);
		make.right.equalTo(self.view.right).with.offset(-15);
        self.calctopconstraint =  make.bottom.equalTo(self.view.top).with.offset([UIWindow interfaceOrientationIsLandscape] ? 389 : 566);
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
    
    self.calculator = [[A3Calculator alloc] initWithLabel:_expressionLabel result:self.evaluatedResultLabel];
    self.calculator.delegate = self;
	
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

- (void)setupBasicKeyPad {
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

- (void)radiandegreeChange {
    if([self radian] == YES) {
        [self.calculator setRadian:FALSE];
        self.radian = NO;
        _degreeandradianLabel.text = @"Degrees";
    } else {
        [self.calculator setRadian:TRUE];
        self.radian = YES;
        _degreeandradianLabel.text = @"Radian";
    }
}

- (HTCopyableLabel *)evaluatedResultLabel {
	if (!super.evaluatedResultLabel) {
		HTCopyableLabel *evaluatedResultLabel = [HTCopyableLabel new];
		evaluatedResultLabel.backgroundColor = [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0];
		evaluatedResultLabel.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:110];
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
		_expressionLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:22];
		_expressionLabel.textColor = [UIColor colorWithRed:159.0/255.0 green:159.0/255.0 blue:159.0/255.0 alpha:1.0];
		_expressionLabel.textAlignment = NSTextAlignmentRight;
		_expressionLabel.text = @"";
		_expressionLabel.lineBreakMode = NSLineBreakByTruncatingHead;
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
	CGFloat scale = [A3UIDevice scaleToOriginalDesignDimension];
    CGFloat vscale = scale;
    
    FNLOGRECT([UIScreen mainScreen].nativeBounds);
    FNLOG(@"%f", [UIScreen mainScreen].nativeScale);
    FNLOGRECT([UIScreen mainScreen].bounds);
    
    if (scientific == NO)
    {
        CGRect bounds = [UIScreen mainScreen].bounds;
        // iPad mini 6th, 1133 x 744
        if (bounds.size.width < bounds.size.height) {
            vscale = bounds.size.height / 1024.0;
            // Portrait
            if (bounds.size.height == 1366.0) {
                self.calctopconstraint.offset(581.5 * scale);
            } else if (bounds.size.height == 1194.0) {
                self.calctopconstraint.offset(700.0);
            } else if (bounds.size.height == 1180.0) {
                self.calctopconstraint.offset(700.0);
            } else if (bounds.size.height == 1112.0) {
                self.calctopconstraint.offset(581.5 * scale);
            } else if (bounds.size.height == 1133.0) {
                // iPad mini 6th
                self.calctopconstraint.offset(730 * scale);
            } else /* if (bounds.size.height == 1024) */ {
                self.calctopconstraint.offset(581.5 * scale);
            }
        } else {
            // Landscape
            if (bounds.size.height == 1024.0) {
                // iPad Pro 12.9"
                self.calctopconstraint.offset(414.5 * scale);
            } else if (bounds.size.width == 1210.0) {
                // iPad Pro 11"
                self.calctopconstraint.offset(420.0);
            } else if (bounds.size.width == 1194.0) {
                // iPad Pro 11"
                self.calctopconstraint.offset(420.0);
            } else if (bounds.size.width == 1180.0) {
                // iPad Air 5th Gen
                self.calctopconstraint.offset(420.0);
            } else if (bounds.size.width == 1112.0) {
                // iPad Pro 10.5"
                self.calctopconstraint.offset(404.5 * scale);
            } else if (bounds.size.width == 1133.0) {
                // iPad mini 6th
                self.calctopconstraint.offset(340 * scale);
            } else /* if (bounds.size.height == 768) */ {
                // Other devices
                self.calctopconstraint.offset(404.5 * scale);
            }
        }
    } else {
        CGRect bounds = [UIScreen mainScreen].bounds;
        
        if (bounds.size.width < bounds.size.height) {
            vscale = bounds.size.height / 1024.0;
            // Portrait
            if (bounds.size.height == 1366.0) {
                self.calctopconstraint.offset(413.5 * scale);
            } else if (bounds.size.height == 1194.0) {
                self.calctopconstraint.offset(520.0);
            } else if (bounds.size.height == 1180.0) {
                self.calctopconstraint.offset(520.0);
            } else if (bounds.size.height == 1112.0) {
                self.calctopconstraint.offset(413.5 * vscale);
            } else if (bounds.size.height == 1133.0) {
                // iPad mini 6th edition
                self.calctopconstraint.offset(490 * vscale);
            } else /* if (bounds.size.height == 1024) */ {
                self.calctopconstraint.offset(413.5 * scale);
            }
        } else {
            // Landscape
            if (bounds.size.height == 1024) {
                // iPad Pro 12.9"
                self.calctopconstraint.offset(273.5 * scale);
            } else if (bounds.size.width == 1210.0) {
                // iPad Pro 11"
                self.calctopconstraint.offset(273.5);
            } else if (bounds.size.width == 1194.0) {
                // iPad Pro 11"
                self.calctopconstraint.offset(273.5);
            } else if (bounds.size.width == 1180.0) {
                // iPad Pro 11"
                self.calctopconstraint.offset(273.5);
            } else if (bounds.size.width == 1112.0) {
                // iPad Pro 10.5"
                self.calctopconstraint.offset(273.5 * scale);
            } else if (bounds.size.width == 1133.0) {
                // iPad mini 6th
                self.calctopconstraint.offset(220 * scale);
            } else /* if (bounds.size.height == 768) */ {
                // Other devices
                self.calctopconstraint.offset(273.5 * scale);
            }
        }
    }
    
    if ([UIWindow interfaceOrientationIsLandscape]) {
        self.calculator.isLandScape = YES;
    } else {
        
        self.calculator.isLandScape = NO;
    }
    
    [self.calculator evaluateAndSet];
}

- (void)keyboardButtonPressed:(NSUInteger)key {

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
    _sharePopoverController =
            [self presentActivityViewControllerWithActivityItems:@[self]
                                               fromBarButtonItem:sender
                                               completionHandler:^() {
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
			NSString *string = [NSString stringWithFormat:@"=%@\n", [self.calculator getResultString]];
			[expression appendAttributedString:[[NSAttributedString alloc] initWithString:string]];
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

#pragma mark -

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController {
	_sharePopoverController = nil;
	[self enableControls:YES];
}


- (void)shareButtonAction:(id)sender {
	[self shareAll:sender];

	[self enableControls:NO];
}


- (BOOL)isCalculationHistoryEmpty {
    Calculation_ *lastcalculation = [Calculation_ findFirstOrderedByAttribute:@"updateDate" ascending:NO];
    if (lastcalculation != nil ) {
        return NO;
    } else {
        return YES;
    }
}

- (void)checkRightButtonDisable {
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

	[[[A3AppDelegate instance] rootViewController_iPad] presentRightSideViewController:viewController toViewController:nil];
}

- (void)ShowMessage:(NSString *)message {
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

@end

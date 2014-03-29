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
#import "common.h"
#import "UIViewController+A3Addition.h"
#import "A3CalculatorButtonsInBasicViewController_iPad.h"
#import "A3CalculatorButtonsInScientificViewController_iPad.h"
#import "A3CalculatorButtonsViewController_iPad.h"
#import "A3Calculator.h"
#import "Calculation.h"
#import "A3ExpressionComponent.h"
#import "A3CalculatorHistoryViewController.h"
#import "UILabel+Boldify.h"
#import "MBProgressHUD.h"
#import "A3KeyboardView.h"


@interface A3CalculatorViewController_iPad ()<A3CalcKeyboardViewIPadDelegate, UIPopoverControllerDelegate, MBProgressHUDDelegate, A3CalcMessagShowDelegate, UITextFieldDelegate>
@property (nonatomic, strong) HTCopyableLabel *expressionLabel;
@property (nonatomic, strong) HTCopyableLabel *evaluatedResultLabel;
@property (nonatomic, strong) UILabel *degreeandradianLabel;
@property (nonatomic, strong) UILabel *basicandscientificLabel;
//@property (nonatomic, strong) UIView *outline;
@property (nonatomic, strong) A3Calculator *calculator;
@property (strong, nonatomic) A3CalculatorButtonsViewController_iPad *calculatorkeypad;
@property (nonatomic, strong) MASConstraint *calctopconstraint;
@property (nonatomic, strong) NSArray *moreMenuButtons;
@property (nonatomic, strong) UIView *moreMenuView;
@property (nonatomic, strong) UIPopoverController *sharePopoverController;
@property (nonatomic, strong) UITextField *textFieldForPlayInputClick;
@property (nonatomic, strong) A3KeyboardView *inputViewForPlayInputClick;

@end

@implementation A3CalculatorViewController_iPad {
    BOOL scientific;
    BOOL radian;
    BOOL _isShowMoreMenu;
    UIBarButtonItem *share;
    UIBarButtonItem *history;
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
    // Do any additional setup after loading the view from its nib.
    [self leftBarButtonAppsButton];
    
    self.navigationItem.hidesBackButton = YES;
    
    share = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"share"] style:UIBarButtonItemStylePlain target:self action:@selector(shareButtonAction:)];
    history = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"history"] style:UIBarButtonItemStylePlain target:self action:@selector(historyButtonAction:)];
    UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    space.width = 24.0;
    
    self.navigationItem.rightBarButtonItems = @[history, space, share];
    [self checkRightButtonDisable];
    radian = YES;
    [self setupSubViews];
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"savedTheLastExpressionInCalculator"]){
        [_calculator setMathExpression:[[NSUserDefaults standardUserDefaults] objectForKey:@"savedTheLastExpressionInCalculator"]];
        [_calculator evaluateAndSet];
        [self checkRightButtonDisable];
    }

	_textFieldForPlayInputClick = [[UITextField alloc] initWithFrame:CGRectZero];
	_textFieldForPlayInputClick.delegate = self;
	_inputViewForPlayInputClick = [[A3KeyboardView alloc] initWithFrame:CGRectMake(0, 0, 1, 1)];
	_textFieldForPlayInputClick.inputView = _inputViewForPlayInputClick;
	[self.view addSubview:_textFieldForPlayInputClick];

	[_textFieldForPlayInputClick becomeFirstResponder];
}

- (BOOL)usesFullScreenInLandscape {
    return YES;
}

- (void) setupSubViews {
    self.view.backgroundColor = [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0];
    CGRect screenBounds = [self screenBoundsAdjustedWithOrientation];

    [self.view addSubview:self.evaluatedResultLabel];
	[_evaluatedResultLabel makeConstraints:^(MASConstraintMaker *make) {
		make.left.equalTo(self.view.left).with.offset(85);
		make.right.equalTo(self.view.right).with.offset(-15);
        self.calctopconstraint =  make.bottom.equalTo(self.view.top).with.offset(screenBounds.size.height == 768 ? 389:566);
		make.height.equalTo(@110);
	}];
    
    [self.view addSubview:self.expressionLabel];
	[_expressionLabel makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.left).with.offset(15);
        make.right.equalTo(self.view.right).with.offset(-15);
        make.top.equalTo(@91);
        make.height.equalTo(@24);
	}];
    
    [self.view addSubview:self.degreeandradianLabel];
    [_degreeandradianLabel makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.left).with.offset(15);
        make.bottom.equalTo(_evaluatedResultLabel.bottom).with.offset(-9.5);
    }];
    
    
    [self.view addSubview:self.basicandscientificLabel];
    [_basicandscientificLabel makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.left).with.offset(15);
        make.top.equalTo(@95);
    }];
    
    UITapGestureRecognizer *basicscientificTapped = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(basicscientifictapAction)];
    [_basicandscientificLabel addGestureRecognizer:basicscientificTapped];
    
    
    _calculator = [[A3Calculator alloc] initWithLabel:_expressionLabel result:_evaluatedResultLabel];
    _calculator.delegate = self;
    
    
    [self.view layoutIfNeeded];

    [self setupBasicKeyPad];
}

- (void) setupBasicKeyPad {
    scientific  = NO;

    _calculatorkeypad  = [[A3CalculatorButtonsInBasicViewController_iPad alloc] initWithNibName:@"A3CalculatorButtonsInBasicViewController_iPad" bundle:nil];

    [self.view addSubview:_calculatorkeypad.view];
    [self addChildViewController:_calculatorkeypad];

 //   [self setHorizontalLineForBasic];
    _degreeandradianLabel.hidden = YES;
    _calculatorkeypad.delegate = self;
    _calculatorkeypad.view.clipsToBounds = YES;
}
     
- (void)setupScientifcKeyPad {
    scientific  = YES;
    
    _calculatorkeypad  = [[A3CalculatorButtonsInScientificViewController_iPad alloc] initWithNibName:@"A3CalculatorButtonsInScientificViewController_iPad" bundle:nil];
	[self.view addSubview:_calculatorkeypad.view];
    [self addChildViewController:_calculatorkeypad];
    
    _calculatorkeypad.delegate = self;
    _degreeandradianLabel.hidden = NO;
    _calculatorkeypad.view.clipsToBounds = YES;
}


-(void) basicscientifictapAction {
    
    [_calculatorkeypad.view removeFromSuperview];
    [_calculatorkeypad removeFromParentViewController];
    _calculatorkeypad.view = nil;
    _calculatorkeypad = nil;
    
    if (scientific == NO)
    {
        scientific = YES;
        [self setupScientifcKeyPad];
    }
    else
    {
        scientific = NO;
        [self setupBasicKeyPad];
        
    }
    
    [self changeCalculatorKindString];
    
}

-(void) radiandegreeChange {
    if(radian == YES) {
        [_calculator setRadian:FALSE];
        radian = NO;
        _degreeandradianLabel.text = @"Degrees";
    } else {
        [_calculator setRadian:TRUE];
        radian = YES;
        _degreeandradianLabel.text = @"Radian";
    }
}

- (HTCopyableLabel *)evaluatedResultLabel {
	if (!_evaluatedResultLabel) {
		_evaluatedResultLabel = [HTCopyableLabel new];
		_evaluatedResultLabel.backgroundColor = [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0];
		_evaluatedResultLabel.font = [UIFont fontWithName:@".HelveticaNeueInterface-Thin" size:110];
		_evaluatedResultLabel.textColor = [UIColor colorWithRed:0.0/255.0 green:0.0/255.0 blue:0.0/255.0 alpha:1.0];
		_evaluatedResultLabel.textAlignment = NSTextAlignmentRight;
		_evaluatedResultLabel.text = @"0";
		_evaluatedResultLabel.adjustsFontSizeToFitWidth = YES;
		_evaluatedResultLabel.minimumScaleFactor = 0.2;
	}
	return _evaluatedResultLabel;
}

- (HTCopyableLabel *)expressionLabel {
	if (!_expressionLabel) {
		_expressionLabel = [HTCopyableLabel new];
		_expressionLabel.backgroundColor =[UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0];
		_expressionLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:22];
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

-(void) changeCalculatorKindString {
    _basicandscientificLabel.text = @"Basic / Scientific";
    if(scientific == YES)
    {
        [_basicandscientificLabel boldSubstring:@"Scientific"];
    }
    else
    {
        [_basicandscientificLabel boldSubstring:@"Basic"];
        
    }
    
}

- (UILabel *)basicandscientificLabel {
    if(!_basicandscientificLabel) {
        _basicandscientificLabel = [UILabel new];
        _basicandscientificLabel.font = [UIFont fontWithName:@"HelvecticaNeue-Light" size:17];
        _basicandscientificLabel.textColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0];
        _basicandscientificLabel.textAlignment = NSTextAlignmentLeft;
        _basicandscientificLabel.userInteractionEnabled = YES;
        [self changeCalculatorKindString];
    }
    
    return _basicandscientificLabel;
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
	@autoreleasepool {
		NSMutableString *shareString = [[NSMutableString alloc] init];
        if (![self.expressionLabel.text hasSuffix:@"="]) {
            [shareString appendString:[NSString stringWithFormat:@"%@=%@\n", _expressionLabel.text, _evaluatedResultLabel.text]];
        } else {
            [shareString appendString:[NSString stringWithFormat:@"%@%@\n", _expressionLabel.text, _evaluatedResultLabel.text]];
        }
        
		_sharePopoverController = [self presentActivityViewControllerWithActivityItems:@[shareString] fromBarButtonItem:sender];
        _sharePopoverController.delegate = self;
        [self.navigationItem.rightBarButtonItems enumerateObjectsUsingBlock:^(UIBarButtonItem *buttonItem, NSUInteger idx, BOOL *stop) {
            [buttonItem setEnabled:NO];
        }];
        
	}
}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController {
    
	[self.navigationItem.rightBarButtonItems enumerateObjectsUsingBlock:^(UIBarButtonItem *buttonItem, NSUInteger idx, BOOL *stop) {
		[buttonItem setEnabled:YES];
	}];
	_sharePopoverController = nil;
}


- (void)shareButtonAction:(id)sender {
	@autoreleasepool {
		[self shareAll:sender];
	}
}


- (BOOL) isCalculationHistoryEmpty {
    Calculation *lastcalculation = [Calculation MR_findFirstOrderedByAttribute:@"date" ascending:NO];
    if (lastcalculation != nil ) {
        return NO;
    } else {
        return YES;
    }
}

- (void) checkRightButtonDisable {
    if ([self isCalculationHistoryEmpty]) {
        history.enabled = NO;
    } else {
        history.enabled = YES;
    }
    
    if([self.expressionLabel.text length] > 0) {
        share.enabled = YES;
    } else {
        share.enabled = NO;
    }
}

#pragma mark - History
- (void)historyButtonAction:(UIButton *)button {
	@autoreleasepool {
        A3CalculatorHistoryViewController *viewController = [[A3CalculatorHistoryViewController alloc] initWithNibName:nil bundle:nil];
        viewController.calculator = self.calculator;
        viewController.iPadViewController = self;
        [self presentSubViewController:viewController];
        
        //	_currencyHistory = nil;
	}
}

- (void)putCalculationHistoryWithExpression:(NSString *)expression{
	@autoreleasepool {
        
		Calculation *lastcalculation = [Calculation MR_findFirstOrderedByAttribute:@"date" ascending:NO];
        NSString *mathExpression = [self.calculator getMathExpression];
		// Compare code and value.
		if (lastcalculation) {
			if ([lastcalculation.expression isEqualToString:mathExpression]) {
				return;
			}
		}
        
        
		Calculation *calculation = [Calculation MR_createEntity];
		NSDate *keyDate = [NSDate date];
        calculation.expression = mathExpression;
        calculation.result = _evaluatedResultLabel.text;
        calculation.date = keyDate;

        [[[MagicalRecordStack defaultStack] context] MR_saveOnlySelfAndWait];
	}
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

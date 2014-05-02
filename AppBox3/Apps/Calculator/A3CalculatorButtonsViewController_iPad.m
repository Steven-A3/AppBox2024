//
//  A3CalculatorButtonsViewController_iPad.m
//  A3TeamWork
//
//  Created by Soon Gyu Kim on 12/24/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import "A3CalculatorButtonsViewController_iPad.h"
#import "A3Calculator.h"
#import "A3ExpressionComponent.h"
#import "A3KeyboardButton_iOS7_iPhone.h"
@interface A3CalculatorButtonsViewController_iPad ()

@end

@implementation A3CalculatorButtonsViewController_iPad {
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
	// Do any additional setup after loading the view.
    for( id buttonTitle in [self buttonTitlesLevel1]) {
        NSUInteger idx = [buttonTitle[kA3CalcButtonIDiPad] integerValue];
        A3KeyboardButton_iOS7_iPhone *button = (A3KeyboardButton_iOS7_iPhone *) [self.view viewWithTag:idx];
        [self setTitle:buttonTitle forButton:button];
        
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

NSString *kA3CalcButtonTitleiPad = @"kA3CalcButtonTitle_iPad";
NSString *kA3CalcButtonIDiPad = @"kA3CalcButtonID_iPad";
- (NSArray *)buttonTitlesLevel1 {
	return @[
             @{kA3CalcButtonTitleiPad:[UIImage imageNamed:@"c_01_1"], kA3CalcButtonIDiPad:@1},
             @{kA3CalcButtonTitleiPad:[UIImage imageNamed:@"c_02_1"], kA3CalcButtonIDiPad:@2},
             @{kA3CalcButtonTitleiPad:[UIImage imageNamed:@"c_03_1"], kA3CalcButtonIDiPad:@3},
             @{kA3CalcButtonTitleiPad:[UIImage imageNamed:@"c_04"], kA3CalcButtonIDiPad:@4},
             @{kA3CalcButtonTitleiPad:[UIImage imageNamed:@"c_06_1"], kA3CalcButtonIDiPad:@9},
             @{kA3CalcButtonTitleiPad:[UIImage imageNamed:@"c_07_1"], kA3CalcButtonIDiPad:@10},
             @{kA3CalcButtonTitleiPad:[UIImage imageNamed:@"c_08_1"], kA3CalcButtonIDiPad:@11},
             @{kA3CalcButtonTitleiPad:[UIImage imageNamed:@"c_09_1"], kA3CalcButtonIDiPad:@12},
             @{kA3CalcButtonTitleiPad:[UIImage imageNamed:@"c_13_1"], kA3CalcButtonIDiPad:@20},
             @{kA3CalcButtonTitleiPad:@"ln", kA3CalcButtonIDiPad:@28},
             @{kA3CalcButtonTitleiPad:[UIImage imageNamed:@"c_20_1"], kA3CalcButtonIDiPad:@36},
             
             @{kA3CalcButtonTitleiPad:[UIImage imageNamed:@"c_10"], kA3CalcButtonIDiPad:@17},
             @{kA3CalcButtonTitleiPad:[UIImage imageNamed:@"c_11"], kA3CalcButtonIDiPad:@18},
             @{kA3CalcButtonTitleiPad:[UIImage imageNamed:@"c_12"], kA3CalcButtonIDiPad:@19},
             @{kA3CalcButtonTitleiPad:[UIImage imageNamed:@"c_13_1"], kA3CalcButtonIDiPad:@20},

             ];
}

- (NSArray *)buttonTitlesLevel2 {
	return @[
             @{kA3CalcButtonTitleiPad:[UIImage imageNamed:@"c_01_2"], kA3CalcButtonIDiPad:@1},
             @{kA3CalcButtonTitleiPad:[UIImage imageNamed:@"c_02_2"], kA3CalcButtonIDiPad:@2},
             @{kA3CalcButtonTitleiPad:[UIImage imageNamed:@"c_03_2"], kA3CalcButtonIDiPad:@3},
             @{kA3CalcButtonTitleiPad:[UIImage imageNamed:@"c_04_p"], kA3CalcButtonIDiPad:@4},
             @{kA3CalcButtonTitleiPad:[UIImage imageNamed:@"c_06_2"], kA3CalcButtonIDiPad:@9},
             @{kA3CalcButtonTitleiPad:[UIImage imageNamed:@"c_07_2"], kA3CalcButtonIDiPad:@10},
             @{kA3CalcButtonTitleiPad:[UIImage imageNamed:@"c_08_2"], kA3CalcButtonIDiPad:@11},
             @{kA3CalcButtonTitleiPad:[UIImage imageNamed:@"c_09_2"], kA3CalcButtonIDiPad:@12},
             @{kA3CalcButtonTitleiPad:[UIImage imageNamed:@"c_13_2"], kA3CalcButtonIDiPad:@20},
             @{kA3CalcButtonTitleiPad:[UIImage imageNamed:@"c_17_2"], kA3CalcButtonIDiPad:@28},
             @{kA3CalcButtonTitleiPad:[UIImage imageNamed:@"c_20_2"], kA3CalcButtonIDiPad:@36},
             ];
}


- (void)setTitle:(NSDictionary *)titleInfo forButton:(A3KeyboardButton_iOS7_iPhone *)button {
	id title = titleInfo[kA3CalcButtonTitleiPad];
	button.identifier = (NSUInteger *)[titleInfo[kA3CalcButtonIDiPad] integerValue];
	if ([title isKindOfClass:[NSString class]]) {
		[button setAttributedTitle:nil forState:UIControlStateNormal];
		[button setTitle:title forState:UIControlStateNormal];
	} else if ([title isKindOfClass:[NSAttributedString class]]) {
		[button setTitle:nil forState:UIControlStateNormal];
		[button setAttributedTitle:title forState:UIControlStateNormal];
	} else if ([title isKindOfClass:[UIImage class]]) {
		[button setTitle:nil forState:UIControlStateNormal];
		[button setAttributedTitle:nil forState:UIControlStateNormal];
		[button setImage:title forState:UIControlStateNormal];
	}
}


- (void)setLevel:(BOOL)level {
    for (id buttonTitle in [self buttonTitlesLevel2]) {
        NSUInteger idx = [buttonTitle[kA3CalcButtonIDiPad] integerValue];
        A3KeyboardButton_iOS7_iPhone *button = (A3KeyboardButton_iOS7_iPhone *) [self.view viewWithTag:idx];
        [button setBackgroundColor:[UIColor colorWithWhite:0 alpha:0.2]];
    }
    
	[UIView animateWithDuration:0.4
						  delay:0
						options:UIViewAnimationOptionCurveLinear
					 animations:^{
                         for( id buttonTitle in [self buttonTitlesLevel2]) {
                             NSUInteger idx = [buttonTitle[kA3CalcButtonIDiPad] integerValue];
                             A3KeyboardButton_iOS7_iPhone *button = (A3KeyboardButton_iOS7_iPhone *) [self.view viewWithTag:idx];
                             [button setBackgroundColor:[UIColor colorWithRed:252.0 / 255.0 green:252.0 / 255.0 blue:253.0 / 255.0 alpha:1.0]];

                         }
                     } completion:^(BOOL finished) {
                         NSArray *targetbuttonTitles = level ? [self buttonTitlesLevel1] : [self buttonTitlesLevel2];
                         
                         for( int i = 0;i < [[self buttonTitlesLevel2] count];i++) {
                             id buttonTitle = [[self buttonTitlesLevel2] objectAtIndex:i];
                             NSUInteger idx = [buttonTitle[kA3CalcButtonIDiPad] integerValue];
                             A3KeyboardButton_iOS7_iPhone *button = (A3KeyboardButton_iOS7_iPhone *) [self.view viewWithTag:idx];
                             [button setImage:nil forState:UIControlStateNormal];
                             [self setTitle:[targetbuttonTitles objectAtIndex:i] forButton:button];
                             
                         }
                    }];
}


- (IBAction)number1action:(id)sender {
    if ([_delegate respondsToSelector:@selector(keyboardButtonPressed:)]) {
        [_delegate keyboardButtonPressed:A3E_1];
    }
}

- (IBAction)sinaction:(id)sender {
    if ([_delegate respondsToSelector:@selector(keyboardButtonPressed:)]) {
        if(!self.secondbutton.isSelected) {
            [_delegate keyboardButtonPressed:A3E_SIN];
        }
        else  {
            [_delegate keyboardButtonPressed:A3E_ASIN];
        }
    }
}

- (IBAction)cosaction:(id)sender {
    if ([_delegate respondsToSelector:@selector(keyboardButtonPressed:)]) {
        if(!self.secondbutton.isSelected) {
            [_delegate keyboardButtonPressed:A3E_COS];
        } else {
            [_delegate keyboardButtonPressed:A3E_ACOS];
        }
        
    }
    
}

- (IBAction)tanaction:(id)sender {
    if ([_delegate respondsToSelector:@selector(keyboardButtonPressed:)]) {
        if(!self.secondbutton.isSelected) {
            [_delegate keyboardButtonPressed:A3E_TAN];
        } else {
            [_delegate keyboardButtonPressed:A3E_ATAN];
        }
    }
}

- (IBAction)secondaction:(id)sender {
	[[UIDevice currentDevice] playInputClick];
	
    A3KeyboardButton_iOS7_iPhone * button = (A3KeyboardButton_iOS7_iPhone *)sender;
    [self setLevel:!button.selected ? 0 : 1];
    button.selected = !button.selected;

}

- (IBAction)clearbutton:(id)sender {
    if ([_delegate respondsToSelector:@selector(keyboardButtonPressed:)]) {
        [_delegate keyboardButtonPressed:A3E_CLEAR];
    }
}

- (IBAction)signaction:(id)sender {
    if ([_delegate respondsToSelector:@selector(keyboardButtonPressed:)]) {
        [_delegate keyboardButtonPressed:A3E_SIGN];
    }
}

- (IBAction)percentaction:(id)sender {
    if ([_delegate respondsToSelector:@selector(keyboardButtonPressed:)]) {
        [_delegate keyboardButtonPressed:A3E_PERCENT];
    }
}

- (IBAction)divideaction:(id)sender {
    if ([_delegate respondsToSelector:@selector(keyboardButtonPressed:)]) {
        [_delegate keyboardButtonPressed:A3E_DIVIDE];
    }
}

- (IBAction)sinhaction:(id)sender {
    if ([_delegate respondsToSelector:@selector(keyboardButtonPressed:)]) {
        if(!self.secondbutton.isSelected) {
            [_delegate keyboardButtonPressed:A3E_SINH];
        } else {
            [_delegate keyboardButtonPressed:A3E_ASINH];
        }
    }
}

- (IBAction)coshaction:(id)sender {
    if ([_delegate respondsToSelector:@selector(keyboardButtonPressed:)]) {
        if(!self.secondbutton.isSelected) {
            [_delegate keyboardButtonPressed:A3E_COSH];
        } else {
            [_delegate keyboardButtonPressed:A3E_ACOSH];
        }
    }
}

- (IBAction)tanhaction:(id)sender {
    if ([_delegate respondsToSelector:@selector(keyboardButtonPressed:)]) {
        if(!self.secondbutton.isSelected) {
            [_delegate keyboardButtonPressed:A3E_TANH];
        } else {
            [_delegate keyboardButtonPressed:A3E_ATANH];
        }
    }
}

- (IBAction)cotaction:(id)sender {
    if ([_delegate respondsToSelector:@selector(keyboardButtonPressed:)]) {
        if(!self.secondbutton.isSelected) {
            [_delegate keyboardButtonPressed:A3E_COT];
        } else {
            [_delegate keyboardButtonPressed:A3E_ACOT];
        }
    }
}

- (IBAction)deleteaction:(id)sender {
    if ([_delegate respondsToSelector:@selector(keyboardButtonPressed:)]) {
        [_delegate keyboardButtonPressed:A3E_BACKSPACE];
    }
}

- (IBAction)leftparenthesisaction:(id)sender {
    if ([_delegate respondsToSelector:@selector(keyboardButtonPressed:)]) {
        [_delegate keyboardButtonPressed:A3E_LEFT_PARENTHESIS];
    }
}

- (IBAction)rightparenthesisaction:(id)sender {
    if ([_delegate respondsToSelector:@selector(keyboardButtonPressed:)]) {
        [_delegate keyboardButtonPressed:A3E_RIGHT_PARENTHESIS];
    }
}

- (IBAction)multiplyaction:(id)sender {
    if ([_delegate respondsToSelector:@selector(keyboardButtonPressed:)]) {
        [_delegate keyboardButtonPressed:A3E_MULTIPLY];
    }
}

- (IBAction)power2action:(id)sender {
    if ([_delegate respondsToSelector:@selector(keyboardButtonPressed:)]) {
            [_delegate keyboardButtonPressed:A3E_SQUARE];
    }
}

- (IBAction)power3action:(id)sender {
    if ([_delegate respondsToSelector:@selector(keyboardButtonPressed:)]) {
        [_delegate keyboardButtonPressed:A3E_CUBE];//
    }
}

- (IBAction)powerxyaction:(id)sender {
    if ([_delegate respondsToSelector:@selector(keyboardButtonPressed:)]) {
        [_delegate keyboardButtonPressed:A3E_POWER_XY];
    }
}

- (IBAction)power10xaction:(id)sender {
    if ([_delegate respondsToSelector:@selector(keyboardButtonPressed:)]) {
        if(!self.secondbutton.isSelected){
            [_delegate keyboardButtonPressed:A3E_POWER_10];
        } else {
            [_delegate keyboardButtonPressed:A3E_POWER_2];
        }
    }
}

- (IBAction)number7action:(id)sender {
    if ([_delegate respondsToSelector:@selector(keyboardButtonPressed:)]) {
        [_delegate keyboardButtonPressed:A3E_7];
    }
}

- (IBAction)number8action:(id)sender {
    if ([_delegate respondsToSelector:@selector(keyboardButtonPressed:)]) {
        [_delegate keyboardButtonPressed:A3E_8];
    }
}

- (IBAction)number9action:(id)sender {
    if ([_delegate respondsToSelector:@selector(keyboardButtonPressed:)]) {
        [_delegate keyboardButtonPressed:A3E_9];
    }
}

- (IBAction)minusaction:(id)sender {
    if ([_delegate respondsToSelector:@selector(keyboardButtonPressed:)]) {
        [_delegate keyboardButtonPressed:A3E_MINUS];
    }
}

- (IBAction)squarerootaction:(id)sender {
    if ([_delegate respondsToSelector:@selector(keyboardButtonPressed:)]) {
        [_delegate keyboardButtonPressed:A3E_SQUAREROOT];
    }
}

- (IBAction)cuberrootaction:(id)sender {
    if ([_delegate respondsToSelector:@selector(keyboardButtonPressed:)]) {
        [_delegate keyboardButtonPressed:A3E_CUBEROOT];
    }
}

- (IBAction)nthrootaction:(id)sender {
    if ([_delegate respondsToSelector:@selector(keyboardButtonPressed:)]) {
        [_delegate keyboardButtonPressed:A3E_NTHROOT];
    }
}

- (IBAction)logaction:(id)sender {
    if ([_delegate respondsToSelector:@selector(keyboardButtonPressed:)]) {
        if(!self.secondbutton.isSelected) {
            [_delegate keyboardButtonPressed:A3E_LN];
        } else {
            [_delegate keyboardButtonPressed:A3E_LOG_Y];
        }
    }
}

- (IBAction)number4action:(id)sender {
    if ([_delegate respondsToSelector:@selector(keyboardButtonPressed:)]) {
        [_delegate keyboardButtonPressed:A3E_4];
    }
}

- (IBAction)number5action:(id)sender {
    if ([_delegate respondsToSelector:@selector(keyboardButtonPressed:)]) {
        [_delegate keyboardButtonPressed:A3E_5];
    }
}

- (IBAction)number6action:(id)sender {
    if ([_delegate respondsToSelector:@selector(keyboardButtonPressed:)]) {
        [_delegate keyboardButtonPressed:A3E_6];
    }
}

- (IBAction)plusaction:(id)sender {
    if ([_delegate respondsToSelector:@selector(keyboardButtonPressed:)]) {
        [_delegate keyboardButtonPressed:A3E_PLUS];
    }
}

- (IBAction)dividexaction:(id)sender {
    if ([_delegate respondsToSelector:@selector(keyboardButtonPressed:)]) {
        [_delegate keyboardButtonPressed:A3E_DIVIDE_X];
    }
}

- (IBAction)factorialaction:(id)sender {
    if ([_delegate respondsToSelector:@selector(keyboardButtonPressed:)]) {
        [_delegate keyboardButtonPressed:A3E_FACTORIAL];
    }
}

- (IBAction)piaction:(id)sender {
    if ([_delegate respondsToSelector:@selector(keyboardButtonPressed:)]) {
        [_delegate keyboardButtonPressed:A3E_PI];
    }
}

- (IBAction)log10action:(id)sender {
    if ([_delegate respondsToSelector:@selector(keyboardButtonPressed:)]) {
        if(!self.secondbutton.isSelected) {
            [_delegate keyboardButtonPressed:A3E_LOG_10];
        } else {
            [_delegate keyboardButtonPressed:A3E_LOG_2];
        }
    }
}

- (IBAction)number2action:(id)sender {
    if ([_delegate respondsToSelector:@selector(keyboardButtonPressed:)]) {
        [_delegate keyboardButtonPressed:A3E_2];
    }
}

- (IBAction)number3action:(id)sender {
    if ([_delegate respondsToSelector:@selector(keyboardButtonPressed:)]) {
        [_delegate keyboardButtonPressed:A3E_3];
    }
}

- (IBAction)operationendaction:(id)sender {
    if ([_delegate respondsToSelector:@selector(keyboardButtonPressed:)]) {
        [_delegate keyboardButtonPressed:A3E_CALCULATE];
    }
}

- (IBAction)enumberaction:(id)sender {
    if ([_delegate respondsToSelector:@selector(keyboardButtonPressed:)]) {
        [_delegate keyboardButtonPressed:A3E_BASE_E];
    }
}

- (IBAction)eenumberaction:(id)sender {
    if ([_delegate respondsToSelector:@selector(keyboardButtonPressed:)]) {
        [_delegate keyboardButtonPressed:A3E_E_Number];
    }
}

- (IBAction)randaction:(id)sender {
    if ([_delegate respondsToSelector:@selector(keyboardButtonPressed:)]) {
        [_delegate keyboardButtonPressed:A3E_RANDOM];
    }
}

- (IBAction)radaction:(id)sender {
    if ([_delegate respondsToSelector:@selector(keyboardButtonPressed:)]) {
        UIButton *button = sender;
        if([button.titleLabel.text isEqualToString:@"Rad"]) {
            [button setTitle:@"Deg" forState:UIControlStateNormal];
        } else {
            [button setTitle:@"Rad" forState:UIControlStateNormal];
        }
        [_delegate keyboardButtonPressed:A3E_RADIAN_DEGREE];
    }
}

- (IBAction)number0action:(id)sender {
    if ([_delegate respondsToSelector:@selector(keyboardButtonPressed:)]) {
        [_delegate keyboardButtonPressed:A3E_0];
    }
}

- (IBAction)commaction:(id)sender {
    if ([_delegate respondsToSelector:@selector(keyboardButtonPressed:)]) {
        [_delegate keyboardButtonPressed:A3E_00];
    }
}

- (IBAction)decimalaction:(id)sender {
    if ([_delegate respondsToSelector:@selector(keyboardButtonPressed:)]) {
        [_delegate keyboardButtonPressed:A3E_DECIMAL_SEPARATOR];
    }
}

@end
